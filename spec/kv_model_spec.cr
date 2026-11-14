require "./helper"

describe Etcd::Model do
  header = Etcdserverpb::ResponseHeader.new(revision: 42_i64)

  describe Etcd::Model::Range do
    it "keeps the reply's header revision" do
      response = Etcdserverpb::RangeResponse.new(
        header: header,
        kvs: [Mvccpb::KeyValue.new(key: "k".to_slice, value: "v".to_slice, mod_revision: 7_i64)],
        count: 1_i64,
      )
      range = Etcd::Model::Range.from_grpc(response)
      range.revision.should eq 42
      range.kvs.first.mod_revision.should eq 7
      range.count.should eq 1
    end

    it "reports revision 0 for a reply without a header" do
      Etcd::Model::Range.from_grpc(Etcdserverpb::RangeResponse.new).revision.should eq 0
    end

    it "keeps the revision of an empty read" do
      range = Etcd::Model::Range.from_grpc(Etcdserverpb::RangeResponse.new(header: header))
      range.kvs.should be_empty
      range.revision.should eq 42
    end

    it "survives an encode and decode" do
      encoded = Etcdserverpb::RangeResponse.new(header: header).to_protobuf.to_slice
      decoded = Etcdserverpb::RangeResponse.from_protobuf(IO::Memory.new(encoded))
      Etcd::Model::Range.from_grpc(decoded).revision.should eq 42
    end
  end

  it "keeps the header revision on puts, deletes and transactions" do
    Etcd::Model::Put.from_grpc(Etcdserverpb::PutResponse.new(header: header)).revision.should eq 42
    Etcd::Model::Put.from_grpc(Etcdserverpb::PutResponse.new).revision.should eq 0
    Etcd::Model::Delete.from_grpc(Etcdserverpb::DeleteRangeResponse.new(header: header)).revision.should eq 42
    Etcd::Model::Delete.from_grpc(Etcdserverpb::DeleteRangeResponse.new).revision.should eq 0
    Etcd::Model::Txn.from_grpc(Etcdserverpb::TxnResponse.new(header: header, succeeded: true)).revision.should eq 42
    Etcd::Model::Txn.from_grpc(Etcdserverpb::TxnResponse.new).revision.should eq 0
  end

  it "keeps a put's previous value" do
    put = Etcd::Model::Put.from_grpc(Etcdserverpb::PutResponse.new(prev_kv: Mvccpb::KeyValue.new(key: "k".to_slice, value: "old".to_slice)))
    put.prev_kv.try(&.value).should eq "old"
  end
end

describe Etcd::Kv do
  describe ".range_request" do
    it "carries a non-zero revision" do
      Etcd::Kv.range_request("k", nil, 100_i64, 42_i64).revision.should eq 42
    end

    it "omits the revision when it is 0" do
      Etcd::Kv.range_request("k", nil, 0_i64, 0_i64).revision.should be_nil
    end
  end

  describe Etcd::Kv::Txn do
    it "builds typed compares and operations" do
      txn = Etcd::Kv::Txn.new
        .compare_value("guard", "g")
        .compare_absent("k")
        .put("k", "v", lease: 5_i64)
        .delete("old")

      txn.compares.size.should eq 2
      value, absent = txn.compares
      value.target.should eq Etcdserverpb::Compare::CompareTarget::VALUE
      value.result.should eq Etcdserverpb::Compare::CompareResult::EQUAL
      value.key.try { |key| String.new(key) }.should eq "guard"
      value.value.try { |v| String.new(v) }.should eq "g"
      absent.target.should eq Etcdserverpb::Compare::CompareTarget::VERSION
      absent.version.should eq 0

      put, delete = txn.success
      put.request_put.try(&.lease).should eq 5
      put.request_put.try(&.value).try { |v| String.new(v) }.should eq "v"
      delete.request_delete_range.try(&.key).try { |key| String.new(key) }.should eq "old"
    end
  end
end

describe Etcd::CompactedError do
  it "recognises etcd's compacted reply" do
    error = GRPC::BadStatus.new(GRPC::StatusCode::OUT_OF_RANGE, "etcdserver: mvcc: required revision has been compacted")
    compacted = Etcd::CompactedError.from?(error, 9_i64).should_not be_nil
    compacted.revision.should eq 9
    compacted.message.should eq "OUT_OF_RANGE: etcdserver: mvcc: required revision has been compacted"
    compacted.should be_a GRPC::BadStatus
  end

  it "leaves other bad statuses alone" do
    Etcd::CompactedError.from?(GRPC::BadStatus.new(GRPC::StatusCode::OUT_OF_RANGE, "etcdserver: mvcc: required revision is a future revision"), 9_i64).should be_nil
    Etcd::CompactedError.from?(GRPC::BadStatus.new(GRPC::StatusCode::UNAVAILABLE, "required revision has been compacted"), 9_i64).should be_nil
  end
end

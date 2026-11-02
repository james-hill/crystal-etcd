require "spec"
require "../src/etcd"
require "../src/etcd/*"

TEST_PREFIX   = "test"
TEST_ROLE     = "#{TEST_PREFIX}role"
TEST_USER     = "#{TEST_PREFIX}user"
TEST_PASSWORD = "#{TEST_PREFIX}_password"
ROOT_ROLE     = "root" # special unicorn root etcd role

NONEXISTENT_ENDPOINT = "http://localhost:9999"

Spec.before_suite do
  Log.setup("*", level: Log::Severity::Debug)
end

Spec.before_each do
  begin
    client = Etcd.from_env

    client.kv.delete_prefix TEST_PREFIX

    client.auth.user_list.select(&.starts_with?(TEST_PREFIX)).each do |test_user|
      client.auth.user_delete(test_user)
    end

    client.auth.role_list.select(&.starts_with?(TEST_PREFIX)).each do |test_role|
      client.auth.role_delete(test_role)
    end
  rescue
  end
end

# A watch starting here sees every later write, however late it registers with etcd
def next_revision : Int64
  marker = "#{TEST_PREFIX}_revision_marker"
  client = Etcd.from_env
  client.kv.put(marker, "")
  (client.kv.range(marker).kvs.first.mod_revision || raise "marker has no revision") + 1
end

def wait_for(attempts = 500, &)
  attempts.times do
    return if yield
    sleep 10.milliseconds
  end
end

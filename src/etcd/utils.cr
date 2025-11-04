module Etcd::Utils
  # Calculate range_end for given prefix
  def self.prefix_range_end(prefix)
    bytes = prefix.to_slice.clone
    # Add to byte array, handling carry
    size = bytes.size
    carry = false
    size.times do |offset|
      index = size - 1 - offset
      if offset == 0 || carry
        bytes[index] += 1
        carry = bytes[index] == UInt8::MIN
      else
        break
      end
    end

    bytes
  end

  def prefix_range_end(prefix)
    Utils.prefix_range_end(prefix)
  end

end

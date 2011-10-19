def encode_message(message_filename, input_filename, output_filename)
  message = ''
  File.open(message_filename, 'r') { |f| message = f.read }
  image = ''
  File.open(input_filename, 'r') { |f| image = f.read.force_encoding('ASCII-8BIT') }
  size = image[2, 4].unpack('L')[0]
  offset = image[10, 4].unpack('L')[0]
  message.each_byte do |message_byte|
    7.downto(0) do |n|
      image_byte = image[offset].unpack('C')[0] & 0b11111110
      image_byte |= 1 unless (message_byte & 2**n) == 0
      image[offset] = [image_byte].pack('C')
      offset += 1
    end
  end
  while offset < size
    image_byte = image[offset].unpack('C')[0] & 0b11111110
    image[offset] = [image_byte].pack('C')
    offset += 1
  end
  File.open(output_filename, 'w') { |f| f.write(image) }
end

encode_message('input.txt', 'input.bmp', 'output.bmp')

def decode_message(filename)
  image = ''
  File.open(filename, 'r') { |f| image = f.read }
  offset = image[10, 4].unpack('L')[0]
  message = ''
  begin
    message_byte = 0
    image[offset, 8].each_byte do |image_byte|
      message_byte <<= 1
      message_byte |= 1 if (image_byte & 1) == 1
    end
    message << message_byte
    offset += 8
  end until message.end_with?("\n")
  message
end

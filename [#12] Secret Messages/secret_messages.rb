class Decrypter
  def self.decrypt_message(input_filename, output_filename)
    encrypted_keyword = encrypted_message = nil
    File.open(input_filename, 'r') do |f|
      encrypted_keyword = f.readline.chomp
      f.readline
      encrypted_message = f.read
    end
    keyword = decrypt_keyword(encrypted_keyword).split('')
    message = ''
    encrypted_message.each_char do |char|
      if ('A'..'Z').include?(char)
        message << decrypt_letter(char, keyword[0])
        keyword.rotate! if ('A'..'Z').include?(char)
      else
        message << char
      end
    end
    File.open(output_filename, 'w') { |f| f.write(message.chomp) }
  end
  
  private
  
  def self.decrypt_keyword(encrypted_keyword)
    possible_keywords = []
    ('A'..'Z').each do |cipher_letter|
      keyword = ''
      encrypted_keyword.each_char do |char|
        keyword << self.decrypt_letter(char, cipher_letter)
      end
      possible_keywords << keyword
    end
    choose_keyword(possible_keywords)
  end
  
  def self.decrypt_letter(encrypted_letter, cipher_letter)
    ordinal = encrypted_letter.ord - (cipher_letter.ord - 'A'.ord)
    ordinal += 26 if ordinal < 'A'.ord
    ordinal.chr
  end
  
  def self.choose_keyword(keywords)
    begin
      puts 'Enter the number of the correct English keyword below:'
      keywords.each_with_index { |keyword, i| puts "#{i + 1}. #{keyword}" }
      print 'Number: '
    end until (1..26) === (choice = gets.to_i)
    keywords[choice - 1]
  end
end

Decrypter.decrypt_message(ARGV.shift, ARGV.shift)
puts 'Decrypted message written to output file'

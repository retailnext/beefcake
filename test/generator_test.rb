require 'beefcake/generator'

class GeneratorTest < Test::Unit::TestCase

  def setup
    # Load up the generator request for the addressbook.proto example
    mock_request = File.read(File.expand_path("../code_generator_request.dat", __FILE__))
    @req = CodeGeneratorRequest.decode(mock_request)
  end

  def test_generate_empty_namespace
    @res = Beefcake::Generator.compile([], @req)
    assert_equal(CodeGeneratorResponse, @res.class)
  end

  def test_generate_top_namespace
    @res = Beefcake::Generator.compile(["Top"], @req)
    assert_equal(CodeGeneratorResponse, @res.class)
    assert_match(/module Top/, @res.file.first.content)
  end

  def test_generate_two_level_namespace
    @res = Beefcake::Generator.compile(["Top", "Bottom"], @req)
    assert_equal(CodeGeneratorResponse, @res.class)
    assert_match(/module Top\s*\n\s*module Bottom/m, @res.file.first.content)
  end

  # Covers the regression of encoding a CodeGeneratorResponse under 1.9.2-p136 raising
  # Encoding::CompatibilityError: incompatible character encodings: ASCII-8BIT and US-ASCII
  def test_encode_decode_generated_response
    @res = Beefcake::Generator.compile([], @req)
    assert_nothing_raised { @res.encode }
  end

  def test_encode_decode_generated_response
    @res = Beefcake::Generator.compile([], @req)
    assert_equal(CodeGeneratorResponse, @res.class)

    round_trip = CodeGeneratorResponse.decode(@res.encode)
    assert_equal round_trip, @res
  end
end

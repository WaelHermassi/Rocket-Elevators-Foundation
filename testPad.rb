client = Aws::Polly::Client.new(region: us-east-1)
client.synthesize_speech(output_format: 'mp3', text: 'hello world', voice_id: 'Matthew')


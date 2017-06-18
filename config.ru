require './app'
require './middlewares/chat_backend'

use Whisper::WhisperBackend
run Whisper::App

require './app'
require './middlewares/whisper_backend'

use Whisper::WhisperBackend
run Whisper::App

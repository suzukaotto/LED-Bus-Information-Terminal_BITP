import os
import module.utils as utils
import requests

class SpeakerManager:
    def __init__(self, GOOGLE_KEY, _OPTIONS):
        self.API_KEY = GOOGLE_KEY
        self.tmp_path = '/src/audio'
        
        self.load_option(_OPTIONS)
        
        self.logging(f"tmp_path : {self.tmp_path}", "info")
        
    def load_option(self, _OPTION):
        self.OPTION = _OPTION
        self.API_ERROR_RETRY_COUNT = self.OPTION['api_error_retry_count']
        self.API_TIMEOUT = self.OPTION['api_timeout']
        
    def logging(self, str: str, type="info") -> bool:
        if self.OPTION['logging'] == False:
            return False
        
        try:
            self.logger
        except AttributeError:
            self.logger = utils.create_logger('info_manager')
        
        if type == "debug":
            self.logger.debug(str)
        elif type == "info":
            self.logger.info(str)
        elif type == "warning" or type == "warn":
            self.logger.warning(str)
        elif type == "error":
            self.logger.error(str)
        elif type == "critical":
            self.logger.critical(str)
        else:
            self.logger.info(str)
            
        return True
    
    def speak_text(self, text):
        url = "https://texttospeech.googleapis.com/v1beta1/voices"
        response = requests.get(url)
        print(response.text)
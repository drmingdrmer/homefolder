#!/usr/bin/env python
# coding: utf-8

# Enable azure speech service:
#  https://docs.azure.cn/zh-cn/ai-services/speech-service/get-started-speech-to-text?tabs=macos%2Cterminal&pivots=programming-language-python
#
# Setup environement variables key and region that are found at page
#  https://portal.azure.com
#  Home -> Azure AI Service | Speech service -> <your_service_name>
#
#  export XP_SEC_AZURE_SPEECH_KEY=***
#  export XP_SEC_AZURE_SERVICE_REGION=***

# Install Dependentcy:
#  pip install azure-cognitiveservices-speech

# Use in CLI:
#  > ./voice-input.py <cn|en>
#    # start speaking...
#    # text will be printed to stdout
#
# Use in vim:
#  - Put `voice-input.py` to a dir defined in $PATH
#  - Add the following line to .vimrc to convert Chinese or English to text:
#    ```
#    inoremap <C-d><C-d> <C-r>=system('voice-input.py cn')<CR>
#    inoremap <C-d><C-e> <C-r>=system('voice-input.py en')<CR>
#    ```
#  - In vim **insert** mode: press Ctrl-d Ctrl-d, then start speaking.
#    The recognized text will be inserted.
#    The max speech time is 30 seconds.


import os
import sys

import azure.cognitiveservices.speech as speechsdk

def load_keys():
    speech_key = os.getenv('XP_SEC_AZURE_SPEECH_KEY')
    region     = os.getenv('XP_SEC_AZURE_SERVICE_REGION')

    assert speech_key is not None
    assert region is not None

    return speech_key, region


def add_phrases(reco, lang):
    my_phrases = {
            'cn': [
                    'Raft',
                    'Paxos',
                    'KV',
                    'RPC',
                    'RTT',

                    'vim',
                    'python',
                    'azure',

                    'stdout',
                    'stderr',

                    'git',
                    'repo',
            ],
            'en': [
            ]

    }

    phrases = speechsdk.PhraseListGrammar.from_recognizer(reco)

    for p in my_phrases[lang]:
        phrases.addPhrase(p)


def recognize(lang):

    languages = {
            'cn': 'zh-cn',
            'en': 'en-US',
    }

    speech_key, region = load_keys()

    speech_config = speechsdk.SpeechConfig(
            subscription=speech_key,
            region=region,
            speech_recognition_language=languages[lang])

    reco = speechsdk.SpeechRecognizer(speech_config=speech_config)


    add_phrases(reco, lang)


    result = reco.recognize_once()
    return result.text

if __name__ == "__main__":
    lang = sys.argv[1]
    print(recognize(lang), end="")

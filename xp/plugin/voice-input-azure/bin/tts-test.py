
# Test Effect of all voice names.
# It generates several *.mps in this dir

import os
import azure.cognitiveservices.speech as speechsdk

speech_key = os.getenv('XP_SEC_AZURE_SPEECH_KEY')
region     = os.getenv('XP_SEC_AZURE_SERVICE_REGION')

# https://learn.microsoft.com/en-us/azure/ai-services/speech-service/how-to-speech-synthesis-viseme?tabs=visemeid&pivots=programming-language-csharp
# https://learn.microsoft.com/en-us/python/api/azure-cognitiveservices-speech/azure.cognitiveservices.speech.speechsynthesisoutputformat?view=azure-python
# https://learn.microsoft.com/en-us/azure/ai-services/speech-service/language-support?tabs=tts#prebuilt-neural-voices
# https://learn.microsoft.com/en-us/azure/ai-services/speech-service/index-text-to-speech
# https://learn.microsoft.com/en-us/azure/ai-services/speech-service/text-to-speech#get-started


#  zh-CN-XiaoxiaoNeural   (Female)
#  zh-CN-XiaoyiNeural     (Female)
#
#  zh-CN-XiaochenNeural   (Female)
#  zh-CN-XiaohanNeural    (Female)
#  zh-CN-XiaomengNeural   (Female)
#  zh-CN-XiaomoNeural     (Female)
#  zh-CN-XiaoqiuNeural    (Female)
#  zh-CN-XiaoruiNeural    (Female)
#  zh-CN-XiaoxuanNeural   (Female)
#  zh-CN-XiaoyanNeural    (Female)
#  zh-CN-XiaozhenNeural   (Female)
#  zh-CN-XiaorouNeural1   (Female)
#  zh-CN-XiaoshuangNeural (Female, Child)
#  zh-CN-XiaoyouNeural    (Female, Child)
#  zh-CN-YunxiNeural      (Male)
#  zh-CN-YunjianNeural    (Male)
#  zh-CN-YunyangNeural    (Male)
#  zh-CN-YunfengNeural    (Male)
#  zh-CN-YunhaoNeural     (Male)
#  zh-CN-YunxiaNeural     (Male)
#  zh-CN-YunyeNeural      (Male)
#  zh-CN-YunzeNeural      (Male)
#  zh-CN-YunjieNeural1    (Male)

voices = [

#  "zh-CN-XiaoxiaoNeural",
#  "zh-CN-XiaoyiNeural",
#  "zh-CN-XiaochenNeural",
#  "zh-CN-XiaohanNeural",
#  "zh-CN-XiaomengNeural",
#  "zh-CN-XiaomoNeural",
"zh-CN-XiaoqiuNeural",
#  "zh-CN-XiaoruiNeural",
#  "zh-CN-XiaoxuanNeural",
#  "zh-CN-XiaoyanNeural",
#  "zh-CN-XiaozhenNeural",
#  "zh-CN-XiaorouNeural",
]

for voice in voices:

    # This example requires environment variables named "SPEECH_KEY" and "SPEECH_REGION"
    speech_config = speechsdk.SpeechConfig(subscription=speech_key, region=region)

    #  speech_config.set_speech_synthesis_output_format(speechsdk.SpeechSynthesisOutputFormat.Riff24Khz16BitMonoPcm)
    speech_config.set_speech_synthesis_output_format(speechsdk.SpeechSynthesisOutputFormat.Audio16Khz32KBitRateMonoMp3)

    #  audio_config = speechsdk.audio.AudioOutputConfig(use_default_speaker=True)
    audio_config = speechsdk.audio.AudioOutputConfig(filename=voice + ".mp3")

    # The language of the voice that speaks.
    #  speech_config.speech_synthesis_voice_name='en-US-JennyNeural'
    speech_config.speech_synthesis_voice_name='zh-CN-XiaohanNeural'
    speech_config.speech_synthesis_voice_name= voice


    speech_synthesizer = speechsdk.SpeechSynthesizer(speech_config=speech_config, audio_config=audio_config)

    # Get text from the console and synthesize to the default speaker.
    #  print("Enter some text that you want to speak >")
    #  text = input()
    text = '白沐霖点点头，“那我寄出去了。”说着拿出了一本新稿纸要誊抄，但手抖得厉害，一个字都写不出来。第一次使油锯的人都是这样，手抖得可能连饭碗都端不住，更别说写字了。'

    speech_synthesis_result = speech_synthesizer.speak_text_async(text).get()

    if speech_synthesis_result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
        print("Speech synthesized for text [{}]".format(text))
    elif speech_synthesis_result.reason == speechsdk.ResultReason.Canceled:
        cancellation_details = speech_synthesis_result.cancellation_details
        print("Speech synthesis canceled: {}".format(cancellation_details.reason))
        if cancellation_details.reason == speechsdk.CancellationReason.Error:
            if cancellation_details.error_details:
                print("Error details: {}".format(cancellation_details.error_details))
                print("Did you set the speech resource key and region values?")

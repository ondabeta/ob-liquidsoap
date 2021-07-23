set("log.file.path", "/dev/null")
set("log.stdout", true)
set("server.telnet", false)
set("osc.port",7777)
set("harbor.bind_addrs",["0.0.0.0"])

# tweak these values if you have lag, skipping, buffer underrun etc
# set("frame.duration",0.04)
# set("root.max_latency",60.)


live = mksafe(input.gstreamer.audio(pipeline="udpsrc port=5555 caps=\"application/x-rtp, media=(string)audio, clock-rate=44100, payload=(int)10\" ! rtpL16depay"))
mic = audio_to_stereo(input.harbor("mic",port=8801,password="{{.Env.ICECAST_SOURCE_PASSWORD}}",buffer=1.0))
live = smooth_add(delay=0.1, p=0.2, normal=live, special=mic)

live = normalize(target = 0., window = 0.03, gain_min = -16., gain_max = 0., live)
live = compress.exponential(live, mu = 1.0)
output.dummy(fallible=true, live)

ms = insert_metadata(live)
# The function to insert metadata
imeta = fst(ms)
# The source with inserted metadata
live = snd(ms)

# Handler for OSC events (gets pairs of strings)
def on_meta(m) =
  # Extract the label
  label = fst(m)
  # Extract the value
  value = snd(m)
  # A debug message
  print("Insert metadata #{label} = #{value}")
  # Insert the metadata
  imeta([(label,value)])
end
# Call the above handler when we have a pair of strings on /metadata
osc.on_string_pair("/metadata",on_meta)



output.icecast(%mp3(bitrate=320), host="{{.Env.ICECAST_HOST}}", port=8000,  password="{{.Env.ICECAST_SOURCE_PASSWORD}}", mount="/ondabeta.mp3", live)
output.icecast(%mp3(bitrate=128), host="{{.Env.ICECAST_HOST}}", port=8000,  password="{{.Env.ICECAST_SOURCE_PASSWORD}}", mount="/oblow.mp3", live)
output.icecast(%fdkaac(channels=2,samplerate=44100, bitrate=64, aot="mpeg4_he_aac_v2"), host="{{.Env.ICECAST_HOST}}", port=8000,  password="{{.Env.ICECAST_SOURCE_PASSWORD}}", mount="/obhe.aac", live)
output.icecast(%fdkaac(channels=2,samplerate=44100, bitrate=256, aot="mpeg4_aac_lc"), host="{{.Env.ICECAST_HOST}}", port=8000,  password="{{.Env.ICECAST_SOURCE_PASSWORD}}", mount="/ob.aac", live)



aac_lofi = %ffmpeg(format="mpegts",
                   codec="aac",
                   channels=2,
                   ar=44100,
                   b="32k")

aac_midfi = %ffmpeg(format="mpegts",
                   codec="aac",
                   channels=2,
                   ar=44100,
                   b="96k")

aac_hifi = %ffmpeg(format="mpegts",
                   codec="aac",
                   channels=2,
                   ar=44100,
                   b="192k")

streams_info = [("aac_lofi",(40000,"mp4a.40.29","ts")),
                ("aac_midfi",(110000,"mp4a.40.2","ts")),
                ("aac_hifi",(220000,"mp4a.40.2","ts"))]
                
streams = [("aac_lofi",aac_lofi), 
           ("aac_midfi", aac_midfi), 
           ("aac_hifi", aac_hifi)]
                
def segment_name(~position,~extname,stream_name) =
  timestamp = int_of_float(gettimeofday())
  duration = 2
  "#{stream_name}_#{duration}_#{timestamp}_#{position}.#{extname}"
end             

output.file.hls(playlist="live.m3u8",
                segment_duration=2.0,
                segments=5,
                segments_overhead=5,
                segment_name=segment_name,
                streams_info=streams_info,
                persist=false,
                persist_at="/state.config",
                "/hls",
                streams,
                live)


# Add to mopidy audio section

# [audio]
# output= shout2send mount=input ip=127.0.0.1 port=8800 password=changeme

# Stream will be available at http://0.0.0.0:8800/mopidy 
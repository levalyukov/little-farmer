extends Label

func _process(_delta):
	text = 'FPS: ' + str(Engine.get_frames_per_second()) + '\nRAM: %d MB' % (OS.get_static_memory_usage() / 1024 / 1024) + "\nCPU: " + str(Performance.get_monitor(Performance.TIME_PROCESS)) + "\nVulkan: " + str(RenderingServer.get_video_adapter_api_version())

sub init()
    m.top.backgroundURI = "pkg:/images/background-controls.jpg"

    m.save_feed_url = m.top.FindNode("save_feed_url")  'Save url to registry

    m.get_channel_list = m.top.FindNode("get_channel_list") 'get url from registry and parse the feed
    m.get_channel_list.ObserveField("content", "SetContent") 'Is thre content parsed? If so, goto SetContent sub and dsipay list

    m.list = m.top.FindNode("list")
    m.list.ObserveField("itemSelected", "setChannel") 

    m.video = m.top.FindNode("Video")
    m.video.ObserveField("state", "checkState")

    showdialog()  'Force a keyboard dialog.  
End sub

' **************************************************************

function onKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    
    if(press) '
        if(key = "right")
            m.list.SetFocus(false)
            m.top.SetFocus(true)
            m.video.translation = [0, 0]
            m.video.width = 0
            m.video.height = 0
            result = true
        else if(key = "left")
            m.list.SetFocus(true)
            m.video.translation = [800, 100]
            m.video.width = 960
            m.video.height = 540
            result = true
        else if(key = "back")
            m.list.SetFocus(true)
            m.video.translation = [800, 100]
            m.video.width = 960
            m.video.height = 540
            result = true
        else if(key = "options")
            showdialog()
            result = true
        end if
    end if
    
    return result 
end function


sub checkState()
    state = m.video.state
    if(state = "error")
        m.top.dialog = CreateObject("roSGNode", "Dialog")
        m.top.dialog.title = "Error: " + str(m.video.errorCode)
        m.top.dialog.message = m.video.errorMsg
    end if
end sub

sub SetContent()    
    m.list.content = m.get_channel_list.content
    m.list.SetFocus(true)
end sub

sub setChannel()
	if m.list.content.getChild(0).getChild(0) = invalid
		content = m.list.content.getChild(m.list.itemSelected)
	else
		itemSelected = m.list.itemSelected
		for i = 0 to m.list.currFocusSection - 1
			itemSelected = itemSelected - m.list.content.getChild(i).getChildCount()
		end for
		content = m.list.content.getChild(m.list.currFocusSection).getChild(itemSelected)
	end if

	'Probably would be good to make content = content.clone(true) but for now it works like this
	'content.streamFormat = "hls"
    content = content.clone(true)

	if m.video.content <> invalid and m.video.content.url = content.url return

	content.HttpSendClientCertificates = true
	content.HttpCertificatesFile = "common:/certs/ca-bundle.crt"
	m.video.EnableCookies()
	m.video.SetCertificatesFile("common:/certs/ca-bundle.crt")
	m.video.InitClientCertificates()

	m.video.content = content

	m.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
	m.video.trickplaybarvisibilityauto = false

	m.video.control = "play"
end sub


sub showdialog()
    PRINT ">>>  ENTERING KEYBOARD <<<"

    keyboarddialog = createObject("roSGNode", "KeyboardDialog")
    keyboarddialog.backgroundUri = "pkg:/images/rsgde_bg_hd.jpg"
    keyboarddialog.title = "Enter .m3u URL"

    keyboarddialog.buttons=["OK","Set back to Demo", "Save", "MoveOnJoy US Channels", "Latino Canales", "Sports Channels", "Peliculas en Audio Latino","Extra channels DEMO"]
    keyboarddialog.optionsDialog=true

    m.top.dialog = keyboarddialog
    m.top.dialog.text = m.global.feedurl
    m.top.dialog.keyboard.textEditBox.cursorPosition = len(m.global.feedurl)
    m.top.dialog.keyboard.textEditBox.maxTextLength = 300

    KeyboardDialog.observeFieldScoped("buttonSelected","onKeyPress")  'we observe button ok/cancel, if so goto to onKeyPress sub
end sub


sub onKeyPress()
    if m.top.dialog.buttonSelected = 0 ' OK
        url = m.top.dialog.text
        m.global.feedurl = url
        m.save_feed_url.control = "RUN"
        m.top.dialog.close = true
        m.get_channel_list.control = "RUN"
    else if m.top.dialog.buttonSelected = 1 ' Set back to Demo
        m.top.dialog.text = "https://pastebin.com/raw/v0dE8SdX"
    else if m.top.dialog.buttonSelected = 2 ' Save
        m.global.feedurl = m.top.dialog.text
        m.save_feed_url.control = "RUN"
        'm.top.dialog.visible ="false"
        'm.top.unobserveField("buttonSelected")
    else if m.top.dialog.buttonSelected = 3 ' MoveOnJoy US Channels
         m.global.feedurl = "https://raw.githubusercontent.com/jsosao/m3u/refs/heads/main/test.m3u8"
        m.save_feed_url.control = "RUN"
        m.top.dialog.close = true
        m.get_channel_list.control = "RUN"
    else if m.top.dialog.buttonSelected = 4 ' Latino Canales
        m.global.feedurl = "https://raw.githubusercontent.com/thedeveloperlad/links_channels/refs/heads/main/latino_channels_only.m3u8"
       m.save_feed_url.control = "RUN"
       m.top.dialog.close = true
       m.get_channel_list.control = "RUN"
    else if m.top.dialog.buttonSelected = 5 ' Sports Channels
        m.global.feedurl = "https://raw.githubusercontent.com/thedeveloperlad/links_channels/refs/heads/main/stream_channels.m3u8"
       m.save_feed_url.control = "RUN"
       m.top.dialog.close = true
       m.get_channel_list.control = "RUN"
    else if m.top.dialog.buttonSelected = 6 ' Peliculas en Audio Latino
        m.global.feedurl = "https://raw.githubusercontent.com/thedeveloperlad/links_channels/refs/heads/main/extra_channels.m3u8"
       m.save_feed_url.control = "RUN"
       m.top.dialog.close = true
       m.get_channel_list.control = "RUN"
    else if m.top.dialog.buttonSelected = 7 ' Extra channels DEMO
        m.global.feedurl = "https://raw.githubusercontent.com/thedeveloperlad/links_channels/refs/heads/main/backup_channels_latino.m3u8"
       m.save_feed_url.control = "RUN"
       m.top.dialog.close = true
       m.get_channel_list.control = "RUN"
    end if
end sub

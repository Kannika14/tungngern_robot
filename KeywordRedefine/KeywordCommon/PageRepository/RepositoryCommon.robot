*** Variables ***
${lblUnreadNumber}    //*[@resource-id='com.calea.echo:id/new_msg']
${lblSenderName}    //*[@resource-id='com.calea.echo:id/name']
${lblTextMessage}    //*[@resource-id='com.calea.echo:id/imm_text']
${btnSmsBack}     //*[@class='android.widget.ImageButton']
${fraUnreadFlag}    //*[@resource-id='com.calea.echo:id/new_msg_parent']
${tempLocatorUnreadWithSender}    //*[@resource-id="com.calea.echo:id/new_msg" and @text="-[totalMsg]-"]/ancestor::*[@resource-id="com.calea.echo:id/infos_layout"]/descendant::*[@resource-id="com.calea.echo:id/name" and @text="-[Sender]-"]
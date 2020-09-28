# macOS 10.15 Catalina xxx.app已损坏，无法打开，你应该将它移到废纸篓解决方法
# https://www.macwk.com/article/mac-catalina-1015-file-damage

disableAppSecurity() {
    sudo spctl --master-disable

    local app
    for app; do
        logAndRun sudo xattr -rd com.apple.quarantine "$app"
    done

    {
        sleep 1m
        sudo spctl --master-enable
    } &
}

enableAppSecurity() {
    sudo spctl --master-enable
}

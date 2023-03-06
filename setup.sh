#!/bin/bash
#!/bin/sh

## Date And Time Variables
tmstamp=$(date "+%Y%m%d-%H:%M:%S")
dstamp=$(date "+%Y%m%d")

## Logs File Variables
LOG_DIR="/var/log/ubuntusoftware/"
mkdir -p $LOG_DIR >/dev/null 2>&1
readonly LOG_FILE="/var/log/ubuntusoftware/error-$dstamp.log"

## Credentials Pop-up For Domain Join
cra() {
    IFS='|' read user pw domi < <(zenity --window-icon ".ubuntusoftware/res/rage.png" --width=300 --height=190 --forms --title="Credentials" --text="Login Details" --add-entry="Username" --add-password="Password" --add-entry="Domain")
    dom=$(echo $domi | awk '{print toupper($0)}')
    us=$user
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --height=25 --error \
            --text="Login Failed !!!"
        # cra
        exit
    fi
}

## Report Generator For Auditing
reprt_add() {
    basfile=/etc/bash.bashrc
    word="report-exportcsv"
    chk_wrd=$(grep -ci "$word" $basfile)
    STRING_SOFT="alias ubuntusoft='bash <(curl -Ss https://raw.githubusercontent.com/AShuuu-Technoid/Ubuntu_Software_Installtion/main/setup.sh)'"

    if [ "$chk_wrd" = "0" ]; then
        printf 'alias report-exportcsv="%s" ' "$(echo "sed 's/|/,/g'")" >>$basfile
        source $basfile
    fi
    if ! grep -q "$STRING_SOFT" "$basfile"; then
        printf "\n$STRING_SOFT" >>$basfile
        source $basfile
        source $basfile
    fi
}

## Logs Generator To Monitor Activities
log() {
    reprt_add
    log_path="/var/log/ubuntusoftware/log"
    reprt_path="/var/log/ubuntusoftware/report"
    log_file="$log_path/setup.log"
    reprt_file="$reprt_path/report-$dstamp.txt"
    if [[ ! -d "$log_path" ]]; then
        mkdir -p $log_path >/dev/null 2>&1

    fi
    if [[ ! -f "$log_file" ]]; then
        echo "PackageName Version Timestamp" >"$log_file"
        chmod -R 655 $log_file
    fi
    if [[ ! -d "$reprt_path" ]]; then
        mkdir -p "$reprt_path" >/dev/null 2>&1
    fi
    if [[ ! -f "$reprt_file" ]]; then
        awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Version" >"$reprt_path/report-$dstamp.txt"
    fi
}

## Delete Script Once Completed
ins_del() {
    zenity --window-icon ".ubuntusoftware/res/question.png" --question --title="Exit" --width=350 --text="Are you sure, You want to delect this Script ?"
    if [ $? = 0 ]; then
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
        rm -rf $SCRIPT_DIR
        rm -r .ubuntusoftware
    else
        exit
    fi
}

## Software Icons Download
rsrt() {
    timeout=30
    for ((i = 0; i <= $timeout; i++)); do
        echo "# System will restart in $(($timeout - $i)) ..."
        echo $((100 * $i / $timeout))
        sleep 1
    done | zenity --window-icon ".ubuntusoftware/res/progress.png" --progress --title="Restarting ..." \
        --window-icon=warning --width=500 --auto-close
    if [ $? = 0 ]; then
        /sbin/reboot
    else
        zenity --window-icon ".ubuntusoftware/res/info.png" --info --width=280 --height=100 --timeout 15 --title="Restart" --text "<span foreground='black' font='13'>Restart manually ...</span>"
    fi
}

## Fix Apt Issue

apt_fix() {
    apt-get install --fix-broken -y >/dev/null 2>&1
}

## Checking Dependencies Is Installed
cl() {
    pkgs='curl'
    if ! dpkg -s $pkgs >/dev/null 2>&1; then
        (
            echo "10"
            sleep 3
            echo "# Checking ... "
            apt-get install $pkgs -y >/dev/null 2>&1
            echo "10"
            sleep 3
            echo "# Installed Repo ... "
        ) | zenity --info --width=250 --timeout=15 --title="Dependencies" --text="<span foreground='black' font='13'>Checking Dependencies\n\n</span> Please wait ..." --ok-label="Cancel"
    fi
}

## Checking Dependencies Is Installed
depet() {
    pkgs='apt-transport-https'
    if ! dpkg -s $pkgs >/dev/null 2>&1; then
        apt-get install $pkgs -y >/dev/null
    fi
}

## Checking Wget Is Installed
wg() {
    pkgs='wget'
    if ! dpkg -s $pkgs >/dev/null 2>&1; then
        apt-get install $pkgs -y >/dev/null
    fi
}

## Checking VS Code Is Installed
vscd_chk() {
    pkgs='code'
    if ! dpkg -s $pkgs >/dev/null 2>&1; then
        vscd
    else
        VSC_VER=$(dpkg -s code | grep Version: | awk -F '-' '{print $1}' | awk '{print $2}')
        zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=250 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'>VS Code Already Installed </span>\n\n<b><i>Version : $VSC_VER   </i></b>✅"
    fi
}

## VS Code Installation
vscd() {
    (
        echo "25"
        sleep 3
        echo "# Downloading VS Code ... "
        wget -O /tmp/code.deb https://update.code.visualstudio.com/latest/linux-deb-x64/stable 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --window-icon ".ubuntusoftware/res/download.png" --progress --width=500 --auto-close --title="Downloading VS Code ..."
        echo "50"
        sleep 3
        echo "# Installing VS Code ... "
        cd /tmp/
        dpkg -i code.deb >/dev/null
        echo "75"
        sleep 3
        echo "# Installed VS Code ... "
        rm -rf /tmp/code.deb
        echo "90"
        sleep 3
        echo "# Removing Download File ... "
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/code.png" --progress \
            --title="Installing VS Code" \
            --text="Please Wait ..." \
            --percentage=0 --auto-close
    VSC_VER=$(dpkg -s code | grep Version: | awk -F '-' '{print $1}' | awk '{print $2}')
    echo "VSCode $VSC_VER $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "VSCode" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=250 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'> VS Code Version </span>\n\n<b><i>Version : $VSC_VER   </i></b>✅"
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## Forticlient VPN Remove
vpn_rm() {
    (
        echo "50"
        echo "Removing Files ..."
        rm -rf /usr/bin/forticlientsslvpn
        echo "100"
        echo "Almost Done ..."
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/forticlient.png" --progress \
            --title="Removing Forticlient" \
            --text="Removing Forticlient..." \
            --percentage=0 --auto-close
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="Installtion Canceled   ❌ "
    fi
}

## Checking Forticlient Is Installed
vpn_chk() {
    vpn_path="/usr/bin/forticlientsslvpn"
    if [[ -d "$vpn_path" ]]; then
        # symc_fchk
        zenity --window-icon ".ubuntusoftware/res/done.png" --question --title="Forticlient Installation" --width=290 --text="<span foreground='black' font='13'>Forticlient Already Installed  ✅</span>\n\n<b><i>Do you want to remove it ?</i></b>"
        if [[ $? -eq 0 ]]; then
            vpn_rm
            vpn_iitm
        elif [ $? -eq 1 ]; then
            zenity --width=200 --error \
                --text="installation Canceled   ❌"
        fi
    else
        vpn_iitm
    fi
}

## Forticlient Installation
vpn_iitm() {
    (
        echo "10"
        echo "Preparing Download ..."
        wget https://cc.iitm.ac.in/sites/default/files/forticlientsslvpn_linux_4.4.2329.tar.gz -P /tmp 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --window-icon ".ubuntusoftware/res/download.png" --progress --width=500 --auto-close --title="VPN"
        echo "40"
        echo "Extracting Files ..."
        gzip -dc /tmp/forticlientsslvpn_linux_4.4.2329.tar.gz | tar -xvzf - >/dev/null 2>&1
        echo "60"
        echo "Copying Files ..."
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
        cp -rf forticlientsslvpn /usr/bin/ >/dev/null 2>&1
        cp -rf $SCRIPT_DIR/.ubuntusoftware/res/forticlient.png /usr/bin/forticlientsslvpn/ >/dev/null 2>&1
        rm -rf forticlientsslvpn
        echo "75"
        echo "Configuring Files ..."
        sed -i -e 's+cd 64bit+cd /usr/bin/forticlientsslvpn/64bit+g' /usr/bin/forticlientsslvpn/fortisslvpn.sh
        printf "[Desktop Entry]
    Version=1.0
    Type=Application
    Terminal=false
    Icon=/usr/bin/forticlientsslvpn/forticlient.png
    Exec=/usr/bin/forticlientsslvpn/64bit/forticlientsslvpn
    Name=Forticlientsslvpn" >/usr/share/applications/forticlientsslvpn.desktop
        echo "100"
        echo "Almost Done ..."
        /usr/bin/forticlientsslvpn/fortisslvpn.sh
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/forticlient.png" --progress \
            --title="Installing Forticlient" \
            --text="Installing Forticlient..." \
            --percentage=0 --auto-close
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --timeout 10 --width=200 --no-wrap --title="Forticlient" --text "<span foreground='black' font='13'><b>Forticlient (IITM)</b>\nInstalled Sucessfully  ✅  </span>"
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="Installtion Canceled   ❌ "
    fi
}

## Network Restarting
rsrt_ser() {
    timeout=10
    for ((i = 0; i <= $timeout; i++)); do
        echo "# Network Is Restarting  : $(($timeout - $i)) ..."
        echo $((100 * $i / $timeout))
        sleep 1
    done | zenity --window-icon ".ubuntusoftware/res/progress.png" --progress --title="Restarting ..." --width=500 --auto-close
    if [ $? = 0 ]; then
        service network-manager restart
    else
        zenity --window-icon ".ubuntusoftware/res/openvpn.png" --info --width=280 --height=100 --timeout 15 --title="Network Restart" --text "<span foreground='black' font='13'>Restart manually ...</span>"
    fi
}

## OpenVPN Installtion
opn_vpn() {
    (
        echo "50"
        sleep 3
        echo "# Installing Packages ..."
        apt-get install network-manager-openvpn-gnome -y >/dev/null 2>&1
        echo "90"
        sleep 3
        echo "# Restarting Services ..."
        rsrt_ser
        echo "100"
        sleep 3
        echo "# Almost Done ..."
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/openvpn.png" --progress \
            --title="Rage VPN" \
            --text="Installing Rage VPN..." \
            --percentage=0 --auto-close
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="Installtion Canceled   ❌ "
    fi
}

## Checking FileZilla Is Installed
filezilla_chk() {
    pkgs='filezilla'
    if ! dpkg -s $pkgs >/dev/null 2>&1; then
        filezilla_ins
    else
        FLZ_VER=$(dpkg -s filezilla | grep Version: | awk -F '-' '{print $1}' | awk '{print $2}')
        zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=250 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'>Filezilla Already Installed </span>\n\n<b><i>Version : $FLZ_VER   </i></b>✅"
    fi
}

## FileZilla Installation
filezilla_ins() {
    (
        echo "25"
        sleep 3
        echo "# Installing Filezilla ... "
        apt_fix
        apt-get install filezilla -y >/dev/null 2>&1
        echo "90"
        sleep 3
        echo "# Installed Filezilla ... "
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/filezilla.png" --progress \
            --title="Filezilla Installation" \
            --text="Filezilla ..." \
            --percentage=0 --auto-close
    FLZ_VER=$(dpkg -s Filezilla | grep Version: | awk -F '-' '{print $1}' | awk '{print $2}')
    echo "Filezilla $FLZ_VER $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Filezilla" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=290 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'> FileZilla Version </span>\n\n<b><i>Version : $FLZ_VER   </i></b>✅"
    if [[ $? == 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## Checking Snap Is Installed
snapd_chk() {
    pkgs='snapd'
    if ! dpkg -s $pkgs >/dev/null 2>&1; then
        apt-get install $pkgs -y >/dev/null 2>&1
    fi
}

postman_rm() {
    (
        echo "55"
        sleep 3
        echo "# Removing Postman ... "
        rm -rf /usr/bin/Postman
        rm -rf /usr/share/applications/Postman.desktop
        snap remove postman >/dev/null 2>&1
        echo "75"
        sleep 3
        echo "# Removing Postman ... "
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/postman.png" --progress \
            --title="Removing Postman" \
            --text="Removing Postman..." \
            --percentage=0 --auto-close
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --timeout 10 --width=200 --no-wrap --title="Postman" --text "<span foreground='black' font='13'><b>Postman </b>\nRemoved Sucessfully  ✅  </span>"
    postman_chk
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="Removing Canceled   ❌ "
    fi
}

postman_chk() {
    snapd_chk
    pkgs='postman'
    if ! $(snap list | grep $pkgs) 2>/dev/null && [[ ! -d "/usr/bin/Postman" ]]; then
        postman_in
    else
        PSM_VER=$(snap list | grep postman | awk '{print $2}')
        zenity --window-icon ".ubuntusoftware/res/done.png" --question --title="Postman Installation" --width=290 --text="<span foreground='black' font='13'>Postman Already Installed  ✅</span>\n\n<b><i>Do you want to update it ?</i></b>"
        if [[ $? -eq 1 ]]; then
            zenity --width=200 --error \
                --text="installation Canceled   ❌"
        else
            postman_rm
        fi
    fi

}

postman_in() {
    (
        echo "15"
        sleep 3
        echo "# Downloading Postman ... "
        wget https://dl.pstmn.io/download/latest/linux64 -P /tmp 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --window-icon ".ubuntusoftware/res/postman.png" --progress --width=500 --auto-close --title="Postman"
        echo "45"
        sleep 3
        echo "# Installing Postman ... "
        tar -xvf /tmp/linux64 -C /usr/bin >/dev/null 2>&1
        echo "75"
        sleep 3
        echo "# Configuring Postman ... "
        printf "[Desktop Entry]
    Name=Postman API Tool
    GenericName=Postman
    Comment=Testing API
    Exec=/usr/bin/Postman/Postman
    Terminal=false
    X-MultipleArgs=false
    Type=Application
    Icon=/usr/bin/Postman/app/resources/app/assets/icon.png
    StartupWMClass=Postman
    StartupNotify=true" >/usr/share/applications/Postman.desktop
        echo "95"
        sleep 3
        echo "# Almost Done ... "
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/postman.png" --progress \
            --title="Postman Installation" \
            --text="Postman ..." \
            --percentage=0 --auto-close
    # PSM_VER=$(snap list | grep postman | awk '{print $2}')
    echo "Postman Latest $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Postman" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=290 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'>Postman Installed  ✅</span>"
    if [[ $? == 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## Checking MYSQL Client Is Installed
mysql_clt_chk() {
    pkgs='mysql-client'
    if ! dpkg -s $pkgs >/dev/null 2>&1; then
        mysql_clt_ins
    else
        MSQC_VER=$(dpkg -s mysql-client | grep Version: | awk -F '-' '{print $1}' | awk '{print $2}')
        zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=250 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'>Mysql-Client Already Installed </span>\n\n<b><i>Version : $MSQC_VER   </i></b>✅"
    fi
}

## MYSQL Installation
mysql_clt_ins() {
    (
        echo "25"
        sleep 3
        echo "# Installing Mysql-Client ... "
        apt-get install mysql-client -y >/dev/null 2>&1
        echo "90"
        sleep 3
        echo "# Installed Mysql-Client ... "
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/mysql.png" --progress \
            --title="Mysql-Client Installation" \
            --text="Mysql ..." \
            --percentage=0 --auto-close
    MSQC_VER=$(dpkg -s mysql-client | grep Version: | awk -F '-' '{print $1}' | awk '{print $2}')
    echo "Mysql-client $MSQC_VER $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Mysql-client" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=290 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'>Mysql-client Version </span>\n\n<b><i>Version : $MSQC_VER   </i></b>✅"
    if [[ $? == 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## Checking Redis Is Installed
redis_chk() {
    pkgs='redis-tools'
    if ! dpkg -s $pkgs >/dev/null 2>&1; then
        redis_ins
    else
        RED_VER=$(dpkg -s redis-tools | grep Version: | awk -F '-' '{print $1}' | awk '{print $2}')
        zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=250 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'>Redis-tools Already Installed </span>\n\n<b><i>Version : $RED_VER   </i></b>✅"
    fi
}

## Redis Installation
redis_ins() {
    (
        echo "25"
        sleep 3
        echo "# Installing Redis-tools ... "
        apt-get install redis-tools -y >/dev/null 2>&1
        echo "90"
        sleep 3
        echo "# Installed Redis-tools ... "
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/redis.png" --progress \
            --title="Redis-tools Installation" \
            --text="Redis-tools ..." \
            --percentage=0 --auto-close
    RED_VER=$(dpkg -s redis-tools | grep Version: | awk -F '-' '{print $1}' | awk '{print $2}')
    echo "Redis-tools $RED_VER $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Redis-tools" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=290 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'>Redis-tools Version </span>\n\n<b><i>Version : $RED_VER   </i></b>✅"
    if [[ $? == 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## Checking Utilities Tools Is Installed
tools_chk() {
    (
        # pkgs='zip'
        echo "15"
        sleep 3
        echo "# Checking Zip ... "
        if ! dpkg -s zip >/dev/null 2>&1; then
            echo "20"
            sleep 3
            echo "# Installing Zip ... "
            apt-get install zip -y >/dev/null 2>&1
            echo "30"
            sleep 3
            echo "# Checking Unzip ... "
        elif ! dpkg -s unzip >/dev/null 2>&1; then
            echo "35"
            sleep 3
            echo "# Installing Unzip ... "
            apt-get install unzip -y >/dev/null 2>&1
            echo "40"
            sleep 3
            echo "# Checking Htop ... "
        elif ! dpkg -s htop >/dev/null 2>&1; then
            echo "45"
            sleep 3
            echo "# Installing Htop ... "
            apt-get install htop -y >/dev/null 2>&1
            echo "50"
            sleep 3
            echo "# Checking Telnet ... "
        elif ! dpkg -s telnet >/dev/null 2>&1; then
            echo "55"
            sleep 3
            echo "# Installing Telnet ... "
            apt-get install telnet -y >/dev/null 2>&1
            echo "60"
            sleep 3
            echo "# Checking Tar ... "
        elif ! dpkg -s tar >/dev/null 2>&1; then
            echo "65"
            sleep 3
            echo "# Installing Tar ... "
            apt-get install tar -y >/dev/null 2>&1
            echo "70"
            sleep 3
            echo "# Checking curl ... "
        elif ! dpkg -s curl >/dev/null 2>&1; then
            echo "75"
            sleep 3
            echo "# Installing curl ... "
            apt-get install curl -y >/dev/null 2>&1
            echo "80"
            sleep 3
            echo "# Checking rsync ... "
        elif ! dpkg -s rsync >/dev/null 2>&1; then
            echo "85"
            sleep 3
            echo "# Installing rsync ... "
            apt-get install rsync -y >/dev/null 2>&1
            echo "90"
            sleep 3
            echo "# Checking nano ... "
        elif ! dpkg -s nano >/dev/null 2>&1; then
            echo "95"
            sleep 3
            echo "# Installing nano ... "
            apt-get install nano -y >/dev/null 2>&1
            echo "100"
            sleep 3
            echo "# Almost Done ... "
        fi
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/rage.png" --progress \
            --title="Utilities Tools" \
            --text="Checking Tools Installed ..." \
            --percentage=0 --auto-close
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="UnInstalltion Canceled   ❌ "
        # ins_del
    fi
}

## User Detection
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
usr_chk() {
    usr=$(users | awk '{print $1}')
    zenity --question --title="Users" --width=290 --text="<span foreground='black' font='13'>User <b>$usr</b> was detected !</span>\n\n<b><i>Do you want to install it ?</i></b>"
    if [ $? = 0 ]; then
        usr_dir
    else
        usr_lst
    fi
}

## User List
usr_lst() {
    usr=$(zenity --list --radiolist --width 200 --height 250 --text "Select playlist from the list below" --title "Please User :" --column "Playlists" --column "Select" --separator="/ " $(ls -d -1 /home/* /home/local/RAGE/* | sed 's|.*/||' | xargs -L1 echo FALSE))
    if [[ $? -eq 1 ]]; then
        zenity --width=200 --error \
            --text="installation Canceled   ❌"
        pj_us="no"
    else
        pj_us="yes"
        usr_dir
    fi
}

## User Directory
usr_dir() {
    usr_path="/home/$usr"
    usr_path1="/home/local/RAGE/$usr"
    if [[ -d "$usr_path" ]]; then
        usrpath=$usr_path
        usr_nm=$usr
        rgk_us="yes"
    elif [[ -d "$usr_path1" ]]; then
        usrpath=$usr_path1
        usr_nm="RAGE\\$usr"
        rgk_us="yes"
    fi
}

## Checking Entry Is Exist
chk_fl() {
    FILE=$usrpath/.bashrc
    FILE1="/etc/sysctl.conf"
    STRING="alias php71_bash='~/projects/php/docker/bin/php71_bash'"
    STRING1="alias php72_bash='~/projects/php/docker/bin/php72_bash'"
    STRING2="alias php73_bash='~/projects/php/docker/bin/php73_bash'"
    STRING3="alias php74_bash='~/projects/php/docker/bin/php74_bash'"
    STRING4="alias php56_bash='~/projects/php/docker/bin/php56_bash'"
    STRING5="alias nginx_bash='~/projects/php/docker/bin/nginx_bash'"
    STRING6="alias redis_bash='~/projects/php/docker/bin/redis_bash'"
    STRING7="alias node_bash='~/projects/php/docker/bin/node_bash'"
    STRING8="alias maria_bash='~/projects/php/docker/bin/mariadb'"
    STRING9="alias docker_php='cd ~/projects/php/docker/; ./bin/start'"
    STRING10="alias docker_home='cd ~/projects/php/docker/'"
    # add in /etc/sysctl.conf
    STRING11="fs.inotify.max_user_watches=524288"
    STRING12="vm.max_map_count = 262144"
    STRING13="fs.file-max = 65536"

    if ! grep -q "$STRING" "$FILE"; then
        echo $STRING >>$FILE
    fi
    if ! grep -q "$STRING1" "$FILE"; then
        echo $STRING1 >>$FILE
    fi
    if ! grep -q "$STRING2" "$FILE"; then
        echo $STRING2 >>$FILE
    fi
    if ! grep -q "$STRING3" "$FILE"; then
        echo $STRING3 >>$FILE
    fi
    if ! grep -q "$STRING4" "$FILE"; then
        echo $STRING4 >>$FILE
    fi
    if ! grep -q "$STRING5" "$FILE"; then
        echo $STRING5 >>$FILE
    fi
    if ! grep -q "$STRING6" "$FILE"; then
        echo $STRING6 >>$FILE
    fi
    if ! grep -q "$STRING7" "$FILE"; then
        echo $STRING7 >>$FILE
    fi
    if ! grep -q "$STRING8" "$FILE"; then
        echo $STRING8 >>$FILE
    fi
    if ! grep -q "$STRING9" "$FILE"; then
        echo $STRING9 >>$FILE
    fi
    if ! grep -q "$STRING10" "$FILE"; then
        echo $STRING10 >>$FILE
    fi
    if ! grep -q "$STRING11" "$FILE1"; then
        echo $STRING11 >>$FILE1
    fi
    if ! grep -q "$STRING12" "$FILE1"; then
        echo $STRING12 >>$FILE1
    fi
    if ! grep -q "$STRING13" "$FILE1"; then
        echo $STRING13 >>$FILE1
    fi
    source $FILE
}

## Docker Project Setup
prj_crt() {
    (
        echo "25"
        sleep 3
        echo "# Preparing ... "
        wrk_pth=$usrpath'/projects/'
        echo "35"
        sleep 3
        echo "# Creating Folders ... "
        mkdir -p $wrk_pth/{drupal,magento,php}
        # cd $wrk_pth
        ##PJ_PASSWD=$(cat .ubuntusoftware/.pjenc.enc | openssl enc -aes-256-cbc -d -a -iter 29 -pass pass:'[jb,9ULWSs]^TP%n')
        PJ_PASSWD="satz%405665"
        url="https://sathishkumar.r1:satz%405665@gitlab.com/ragecom/rage2/docker-php.git"
        echo "40"
        sleep 3
        echo "# Cloning Files ... "
        git clone $url $wrk_pth'php' >/dev/null 2>&1
        echo "50"
        sleep 3
        echo "# Configuring Files ... "
        rm -rf $wrk_pth'php'/.git
        chmod -R 777 $wrk_pth'php'/data/ $wrk_pth'php'/logs/
        echo "60"
        sleep 3
        echo "# Configuring Files ... "
        chown -R $usr_nm:$usr_nm $wrk_pth
        echo "75"
        sleep 3
        echo "# Setting Up Some Files ... "
        chk_fl
        echo "95"
        sleep 3
        echo "# Almost Done ... "

    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/rage.png" --progress \
            --title="Project Setup" \
            --text="Processing ..." \
            --percentage=0 --auto-close
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="UnInstalltion Canceled   ❌ "
        # ins_del
    fi
}
proj_finl() {
    usr_chk
    prj_crt
    chk_fl
    apache_stop

}

## Checkinf Meld Is Installed
mld_chk() {
    pkgs='meld'
    if ! dpkg -s $pkgs >/dev/null 2>&1; then
        mld
    else
        MLD_VER=$(dpkg -s meld | grep Version: | awk -F '-' '{print $1}' | awk '{print $2}')
        zenity --window-icon ".ubuntusoftware/res/meld.png" --info --width=290 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'> Meld Already Installed </span>\n\n<b><i>Version : $MLD_VER   </i></b>✅"
    fi
}

## Meld Installation
mld() {
    (
        echo "25"
        sleep 3
        echo "# Installing Meld ... "
        apt-get install meld -y >/dev/null 2>&1
        echo "90"
        sleep 3
        echo "# Installed Meld ... "
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/meld.png" --progress \
            --title="Meld Installation" \
            --text="Meld ..." \
            --percentage=0 --auto-close
    MLD_VER=$(dpkg -s meld | grep Version: | awk -F '-' '{print $1}' | awk '{print $2}')
    echo "Meld $MLD_VER $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Meld" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=290 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'> Meld Version </span>\n\n<b><i>Version : $MLD_VER   </i></b>✅"
    if [[ $? == 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## Checking Chrome Is Installed
chrm_chk() {
    pkgs='google-chrome-stable'
    if ! dpkg -s $pkgs >/dev/null 2>&1; then
        chrm
    else
        CHRM_VER=$(dpkg -s google-chrome-stable | grep Version: | awk -F '-' '{print $1}' | awk '{print $2}' | awk 'BEGIN{FS=OFS="."} NF--' | awk 'BEGIN{FS=OFS="."} NF--')
        zenity --window-icon ".ubuntusoftware/res/chrome.png" --info --width=280 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'> Chrome Already Installed </span>\n\n<b><i>Version : $CHRM_VER   </i></b>✅"
    fi
}

## Chrome Installtion
chrm() {
    (
        echo "25"
        sleep 3
        echo "# Downloading Chrome ... "
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P /tmp 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --window-icon ".ubuntusoftware/res/download.png" --progress --width=500 --auto-close --title="Google Chrome"
        echo "60"
        sleep 3
        echo "# Installing Chrome ... "
        dpkg -i /tmp/google-chrome-stable_current_amd64.deb >/dev/null 2>&1
        echo "75"
        sleep 3
        echo "# Reoving Download file ... "
        rm -rf /tmp/google-chrome-stable_current_amd64.deb >/dev/null 2>&1
        echo "90"
        sleep 3
        echo "# Installed 👍 "
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/chrome.png" --progress \
            --title="Chrome Installation" \
            --text="Preparing ..." \
            --percentage=0 --auto-close
    CHRM_VER=$(dpkg -s google-chrome-stable | grep Version: | awk -F '-' '{print $1}' | awk '{print $2}' | awk 'BEGIN{FS=OFS="."} NF--' | awk 'BEGIN{FS=OFS="."} NF--')
    echo "Chrome $CHRM_VER $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Chrome" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=280 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'> Chrome Version </span>\n\n<b><i>Version : $CHRM_VER   </i></b>✅"
    if [[ $? == 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## Checking Firefox Is Installed
firefx_chk() {
    pkgs='firefox'
    if ! dpkg -s $pkgs >/dev/null 2>&1; then
        firefx
    else
        FIREFX_VER=$(dpkg -s firefox | grep Version: | awk -F '-' '{print $1}' | awk '{print $2}' | awk 'BEGIN{FS=OFS="."} NF--')
        zenity --window-icon ".ubuntusoftware/res/firefox.png" --info --width=280 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'> Firefox Already Installed </span>\n\n<b><i>Version : $FIREFX_VER   </i></b>✅"
    fi
}

## Firefox Installtion
firefx() {
    (
        echo "25"
        echo "# Adding Repo... "
        add-apt-repository ppa:mozillateam/firefox-next -y >/dev/null 2>&1
        echo "50"
        echo "# Updating Repo ... "
        apt update -y >/dev/null 2>&1
        echo "70"
        echo "# Installing Firefox ... "
        apt install firefox -y >/dev/null 2>&1
        echo "95"
        echo "# Installed Firefox "
        sleep 3
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/firefox.png" --progress \
            --title="Firefox Installation" \
            --text="Preparing ..." \
            --percentage=0 --auto-close
    FIREFX_VER=$(dpkg -s firefox | grep Version: | awk -F '-' '{print $1}' | awk '{print $2}' | awk 'BEGIN{FS=OFS="."} NF--')
    echo "Firefox $FIREFX_VER $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Firefox" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=280 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'> Firefox Version </span>\n\n<b><i>Version : $FIREFX_VER   </i></b>✅"
    if [[ $? == 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## Checking ScreenTime Is Installed
scntm_chk() {
    pkgs='screentime'
    if ! dpkg -s $pkgs >/dev/null 2>&1; then
        scntm
    else
        SCT_VER=$(dpkg -s $pkgs | grep Version: | awk -F '-' '{print $1}' | awk '{print $2}')
        zenity --window-icon ".ubuntusoftware/res/rage.png" --info --width=290 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'>Screen Time Already Installed</span>\n\n<b><i>Version :  $SCT_VER  </i></b>✅"
    fi
}

## ScreenTime Installation
scntm() {
    (
        echo "25"
        sleep 3
        echo "# Preparing ... "
        PASSWD=$(cat .ubuntusoftware/.encry.enc | openssl enc -aes-256-cbc -d -a -iter 29 -pass pass:'Lwg&u@qRnS$CwLJ9PBU5RV&w^J5EXnQ^$2s!9@e2+!$PYU$A79')
        url="http://rg1rage:$PASSWD@wip10.ragedev.com/it-tools/screentime/linux.zip"
        echo "45"
        sleep 3
        echo "# Downloading ScreenTime ... "
        wget $url -P /tmp/ 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --window-icon ".ubuntusoftware/res/download.png" --progress --width=500 --auto-close --title="Downloading Screen Time ..."
        echo "70"
        sleep 3
        echo "# Installing ScreenTime ... "
        unzip /tmp/linux.zip -d /tmp/ >/dev/null
        echo "80"
        sleep 3
        echo "# Installing ScreenTime ... "
        dpkg -i /tmp/Screentime.deb >/dev/null 2>&1
        echo "90"
        sleep 3
        echo "# Installed ScreenTime ... "
        rm -rf /tmp/Screentime.deb >/dev/null 2>&1
        rm -rf /tmp/linux.zip >/dev/null 2>&1
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/rage.png" --progress \
            --title="Screen Time Installation" \
            --text="Preparing ..." \
            --percentage=0 --auto-close
    SCT_VER=$(dpkg -s screentime | grep Version: | awk -F '-' '{print $1}' | awk '{print $2}')
    echo "Screen-Time $SCT_VER $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Screen-Time" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/rage.png" --info --width=290 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'>Screen Time Installed</span>\n\n<b><i>Version :  $SCT_VER  </i></b>✅"
    if [[ $? == 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## Checking Users For RageKiosk
rgk_usr_chk() {
    usr=$(users | awk '{print $1}')
    zenity --question --title="Users" --width=290 --text="<span foreground='black' font='13'>User <b>$usr</b> was detected !</span>\n\n<b><i>Do you want to install it ?</i></b>"
    if [ $? = 0 ]; then
        rgk_usr_dir
    elif [ $? = 1 ]; then
        rgk_usr_lst
    else
        zenity --width=200 --error \
            --text="installation Canceled   ❌"
        exit
    fi
}

## Users List For RageKiosk
rgk_usr_lst() {
    usr=$(zenity --list --radiolist --width 200 --height 250 --text "Select playlist from the list below" --title "Please User :" --column "Playlists" --column "Select" --separator="/ " $(ls -d -1 /home/* /home/local/RAGE/* | sed 's|.*/||' | xargs -L1 echo FALSE))
    if [[ $? -eq 1 ]]; then
        zenity --width=200 --error \
            --text="installation Canceled   ❌"
        rgk_us="no"
    else
        rgk_us="yes"
        rgk_usr_dir
    fi
}

## Users Directory For RageKiosk
rgk_usr_dir() {
    usr_path="/home/$usr"
    usr_path1="/home/local/RAGE/$usr"
    if [[ -d "$usr_path" ]]; then
        usrpath=$usr_path
        usr_nm=$usr
        rgk_us="yes"
    elif [[ -d "$usr_path1" ]]; then
        usrpath=$usr_path1
        usr_nm="RAGE\\$usr"
        rgk_us="yes"
    fi
}

## RageKiosk Remove
rgk_rm() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
    cd "$usrpath/RageKiosk"
    ./RageKiosk-uninstall.sh &>/dev/null
    cd $SCRIPT_DIR
}

## RageKiosk Installtion
rgk_ins_chk() {
    rgk_usr_chk
    rgk_fl="$usrpath/RageKiosk"
    if [[ -d "$rgk_fl" ]]; then
        # symc_fchk
        zenity --window-icon ".ubuntusoftware/res/done.png" --question --title="Rage Kiosk Installation" --width=290 --text="<span foreground='black' font='13'>Rage Kiosk Already Installed  ✅</span>\n\n<b><i>Do you want to remove it ?</i></b>"
        if [[ $? -eq 1 ]]; then
            zenity --width=200 --error \
                --text="installation Canceled   ❌"
        else
            rgk_rm
            rgkiosk
        fi
    else
        rgkiosk
    fi
}

## Check Ragekiosk Is Installed
rgk_chk() {
    zenity --window-icon ".ubuntusoftware/res/question.png" --question --width=350 --text="<span foreground='black' font='13'> Did you know <b>EMP Code</b> ?</span>" --ok-label="Yes" --cancel-label="No"
    if [ $? = 0 ]; then
        # echo "yes"
        rgk_chk_cod
    elif [ $? = 1 ]; then
        rgk_chk_nm
    fi
}

## RageKiosk EMP Code
rgk_chk_nm() {
    rgk_um=$(zenity --entry --width=200 --title "Rage Kiosk" --text "Enter Emp Name : ")
    if [[ ! -z "$rgk_um" ]]; then
        chusr=$rgk_um
        echo $chusr
    else
        zenity --width=200 --error \
            --text="Invalid Emp Name ❌"
        exit
    fi
}

## Checking EMP Code Is Exist
rgk_chk_cod() {
    cod=$(zenity --entry --width=200 --title "Rage Kiosk" --text "Enter Emp Code : ")
    if ! grep -wq $cod "/tmp/ragekiosk/support/userlist.txt"; then
        zenity --width=200 --error \
            --text="Invalid Emp Code ❌"
        exit
    else
        chusr=$(awk "/$cod/" /tmp/ragekiosk/support/userlist.txt | awk 'NR==1 {print $2}')
    fi
}

## RageKiosk Tools Install
rgk_dep() {
    pkgs='libxcb-xinerama0'
    if ! dpkg -s $pkgs >/dev/null 2>&1; then
        pkexec --disable-internal-agent apt install libxcb-xinerama0 -y >/dev/null 2>&1
    fi
}

## RageKiosk Configuration
rgkiosk_set() {
    chmod +x /tmp/ragekiosk/InstallerRageKiosk.run
    sudo -u $usr_nm /tmp/ragekiosk/InstallerRageKiosk.run >/dev/null 2>&1
    sed -i '/export QT_QPA_PLATFORM_PLUGIN_PATH=/a export DISPLAY=:0' $usrpath/RageKiosk/RageKiosk/RageKiosk.sh
    line="30 * * * * /bin/sh $usrpath/RageKiosk/RageKiosk/RageKiosk.sh"
    line2="@reboot sleep 60 && /bin/sh $usrpath/RageKiosk/RageKiosk/RageKiosk.sh"
    (
        crontab -u $usr_nm -l 2>/dev/null
        echo "$line"
        echo "$line2"
    ) | crontab -u $usr_nm -
    # (crontab -l 2>/dev/null; echo "$line" ; echo "$line2" ) | crontab -
    # chusr=$(awk "/$cod/" /tmp/ragekiosk/support/userlist.txt | awk 'NR==1 {print $2}')
    sed -i -e "s/username=.*/username=$chusr/g" /tmp/ragekiosk/support/RageKiosk/loginInfo/userInformation.ini
    mkdir -p $usrpath/.local/share/RageKiosk
    cp -rf /tmp/ragekiosk/support/RageKiosk/* $usrpath/.local/share/RageKiosk/
    cp -rf /tmp/ragekiosk/support/RageKiosk-uninstall.sh $usrpath/RageKiosk/
    chown -R $usr_nm $usrpath/.local/share/RageKiosk
    chmod 777 $usrpath/.local/share/RageKiosk/log
    sudo -u $usr_nm sh $usrpath/RageKiosk/RageKiosk/RageKiosk.sh >/dev/null 2>&1
}

## RageKiosk Remove
rgkiosk_rm() {
    rm -rf /tmp/ragekiosk >/dev/null 2>&1
    rm -rf /tmp/linux.zip* >/dev/null 2>&1
}

## RageKiosk Installation
rgkiosk() {
    (
        if [[ $rgk_us == "yes" ]]; then
            echo "10"
            sleep 3
            echo "# Preparing ... "
            PASSWD=$(cat .ubuntusoftware/.encry.enc | openssl enc -aes-256-cbc -d -a -iter 29 -pass pass:'Lwg&u@qRnS$CwLJ9PBU5RV&w^J5EXnQ^$2s!9@e2+!$PYU$A79')
            url="http://rg1rage:$PASSWD@wip10.ragedev.com/it-tools/ragekiosk/linux.zip"
            echo "20"
            sleep 3
            echo "# Downloading Rage Kiosk ... "
            wget $url -P /tmp/ 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --window-icon ".ubuntusoftware/res/download.png" --progress --width=500 --auto-close --title="Downloading Rage Kiosk ..."
            echo "30"
            sleep 3
            echo "# Preparing Rage Kiosk ... "
            rm -rf /tmp/ragekiosk >/dev/null 2>&1
            mkdir /tmp/ragekiosk >/dev/null
            unzip /tmp/linux.zip -d /tmp/ragekiosk/ >/dev/null
            echo "40"
            sleep 3
            echo "# Checking User ... "
            # rgk_usr_chk
            echo "50"
            sleep 3
            echo "# Checking User ... "
            rgk_chk
            echo "60"
            sleep 3
            echo "# Installing Dependencies ... "
            rgk_dep
            echo "70"
            sleep 3
            echo "# Installing Rage Kiosk ... "
            rgkiosk_set
            echo "80"
            sleep 3
            echo "# Removing packages ... "
            rgkiosk_rm
            echo "90"
            sleep 3
            echo "# Installed Rage Kiosk ... "
            zenity --window-icon ".ubuntusoftware/res/rage.png" --info --width=290 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'>Rage Kiosk Installed</span>  ✅"
            echo "Ragekiosk NA $tmstamp" >>$log_file
            awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Ragekiosk" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
        fi
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/rage.png" --progress \
            --title="Rage Kiosk Installation" \
            --text="Preparing ..." \
            --percentage=0 --auto-close
    if [[ $? == 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
    fi
}
## Checking Symantec Is Installed
symc_chk() {
    file="/usr/lib/symantec/version.sh"
    if [[ -f "$file" ]]; then
        zenity --window-icon ".ubuntusoftware/res/done.png" --question --title="Symantec Installation" --width=290 --text="<span foreground='black' font='13'>Symantec Endpoint Protection Installed  ✅</span>\n\n<b><i>Do you want to remove it ?</i></b>"
        if [ $? = 0 ]; then
            symc_rm
            symc_ins_1
        fi
    else
        symc_ins_1
    fi
}

## Symantec Remove
symc_rm() {
    (
        echo "45"
        sleep 3
        echo "# Preparing Removal ... "
        cd /usr/lib/symantec/
        echo "60"
        sleep 3
        echo "# Removing Symantec Endpoint Protection ... "
        ./uninstall.sh >/dev/null
        echo "90"
        sleep 3
        echo "# Removed Symantec Endpoint Protection ... "
    ) |
        zenity --window-icon ".ubuntusoftware/res/symantec.png" --width=500 --progress \
            --title="Symantec Endpoint Protection Installation" \
            --text="Removing ..." \
            --percentage=0 --auto-close
    if [[ $? == 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
    fi
}

## Symantec Installation For 150 Users
symc_ins_1() {
    (
        echo "25"
        sleep 3
        echo "# Preparing ... "
        url="https://bds.securitycloud.symantec.com/v1/downloads/n2Z_J97PMkYnpbEJK9B3yg-7QLc"
        echo "50"
        sleep 3
        echo "# Downloading Symantec Endpoint Protection ... "
        wget -O /tmp/LinuxInstaller $url 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --window-icon ".ubuntusoftware/res/download.png" --progress --width=500 --auto-close --title="Downloading SEP ..."
        echo "70"
        sleep 3
        echo "# Installing Symantec Endpoint Protection ... "
        cd /tmp/
        chmod +x LinuxInstaller
        ./LinuxInstaller >/dev/null
        echo "80"
        sleep 3
        echo "# Configurating Symantec Endpoint Protection ... "
        cd /usr/lib/symantec/
        ./version.sh >/tmp/symver.txt
        echo "90"
        sleep 3
        echo "# Installed Symantec Endpoint Protection ... "
        rm -rf /tmp/LinuxInstaller
    ) |
        zenity --window-icon ".ubuntusoftware/res/symantec.png" --width=500 --progress \
            --title="Symantec Endpoint Protection Installation" \
            --text="Checking ..." \
            --percentage=0 --auto-close
    SYMC_VER=$(cat /tmp/symver.txt | grep "Symantec Endpoint Protection (Cloud)" | awk 'NR==1 {print $5}' | awk -F '.' '{print $1 "." $2}')
    SER="(SERVER-1)"
    echo "Symantec $SYMC_VER-$SER $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Symantec" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=290 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'>Symantec Endpoint Protection Installed</span>\n\n<b><i>SEP Linux Version : $SYMC_VER </i></b>✅"
    cd /tmp/
    rm -rf LinuxInstaller symver.txt >/dev/null
    if [[ $? == 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
    fi
}

## Symantec Installation For 50 Users
symc_ins_2() {
    (
        echo "25"
        sleep 3
        echo "# Preparing ... "
        url="https://bds.securitycloud.symantec.com/v1/downloads/8PZXtlH-5SsHTjb038ui_nI_BQM"
        echo "50"
        sleep 3
        echo "# Downloading Symantec Endpoint Protection ... "
        wget -O /tmp/LinuxInstaller $url 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --window-icon ".ubuntusoftware/res/download.png" --progress --width=500 --auto-close --title="Downloading SEP ..."
        echo "70"
        sleep 3
        echo "# Installing Symantec Endpoint Protection ... "
        cd /tmp/
        chmod +x LinuxInstaller
        ./LinuxInstaller >/dev/null
        echo "80"
        sleep 3
        echo "# Configurating Symantec Endpoint Protection ... "
        cd /usr/lib/symantec/
        ./version.sh >/tmp/symver.txt
        echo "90"
        sleep 3
        echo "# Installed Symantec Endpoint Protection ... "
        rm -rf /tmp/LinuxInstaller
    ) |
        zenity --window-icon ".ubuntusoftware/res/symantec.png" --width=500 --progress \
            --title="Symantec Endpoint Protection Installation" \
            --text="Checking ..." \
            --percentage=0 --auto-close
    SYMC_VER=$(cat /tmp/symver.txt | grep "Symantec Endpoint Protection (Cloud)" | awk 'NR==1 {print $5}' | awk -F '.' '{print $1 "." $2}')
    SER="(SERVER-2)"
    echo "Symantec $SYMC_VER-$SER $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Symantec" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=290 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'>Symantec Endpoint Protection Installed</span>\n\n<b><i>SEP Linux Version : $SYMC_VER </i></b>✅"
    cd /tmp/
    rm -rf LinuxInstaller symver.txt >/dev/null
    if [[ $? == 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
    fi

}
## Symantec Choise
# symc_ins() {

#     SymantecType=$(zenity --window-icon ".ubuntusoftware/res/rage.png" --width=250 --height=190 --list --radiolist \
#         --title 'Symantec Server' \
#         --text 'Symantec Installation' \
#         --column 'Select' \
#         --ok-label="Next" \
#         --column 'Actions' TRUE "Server 1 (150 Users)" FALSE "Server 2 (50 Users)")
#     if [[ $? -eq 1 ]]; then
#         zenity --window-icon ".ubuntusoftware/res/error.png" --error --title="Declined" --width=200 \
#             --text="installation Canceled   ❌"
#         ins_del
#         exit 1
#     elif [[ $SymantecType == "Server 1 (200 Users)" ]]; then
#         symc_ins_1
#     #elif [[ $SymantecType == "Server 2 (50 Users)" ]]; then
#     #    symc_ins_2
#     fi

# }

## Checking Pinta Is Installed
pinta_chk() {
    pkgs='pinta'
    if ! dpkg -s $pkgs >/dev/null 2>&1; then
        pinta_ins
    else
        PIN_VER=$(pinta --version)
        zenity --window-icon ".ubuntusoftware/res/pinta.png" --info --timeout 10 --width=250 --height=100 --title="Pinta" --text "<span foreground='black' font='13'> Pinta Already Installed </span>\n\n<b><i>Version : $PIN_VER </i></b>✅"
    fi
}

## Painta Installtion
pinta_ins() {
    (
        echo "10"
        sleep 3
        echo "# Adding Repository ... "
        add-apt-repository ppa:pinta-maintainers/pinta-stable -y >/dev/null 2>&1
        echo "49"
        sleep 3
        echo "# Added Repo ... "
        apt-get update -y >/dev/null 2>&1
        echo "70"
        sleep 3
        echo "# Added Repo ... "
        apt-get install pinta -y >/dev/null 2>&1
        echo "90"
        sleep 3
        echo "# Added Repo ... "
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/pinta.png" --progress \
            --title="Pinta Installation" \
            --text="Checking ..." \
            --percentage=0 --auto-close
    PIN_VER=$(pinta --version)
    echo "Pinta $PIN_VER $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Pinta" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/pinta.png" --info --timeout 10 --width=250 --height=100 --title="Pinta" --text "<span foreground='black' font='13'> Pinta Installed </span>\n\n<b><i>Version : $PIN_VER </i></b>✅"
    if [[ $? == 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
    fi
}

## Domain Package Installation
domainjoin() {
    cra
    (
        echo "5"
        sleep 3
        echo "# Creating tmp ... "
        cd /tmp
        echo "10"
        sleep 3
        echo "# Downloading Packages ..."
        wget https://github.com/Darkshadee/pbis-open/releases/download/9.1.0/pbis-open-9.1.0.551.linux.x86_64.deb.sh 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --window-icon ".ubuntusoftware/res/download.png" --progress --width=500 --auto-close --title="Domain Joining"
        echo "15"
        sleep 3
        echo "# Running Script ..."
        sh pbis-open-9.1.0.551.linux.x86_64.deb.sh >/dev/null 2>&1
        echo "20"
        sleep 3
        echo "# Pbis Running ..."
        # cd pbis-open-9.1.0.551.linux.x86_64.deb
        echo "30"
        sleep 3
        echo "# Permission Changing ..."
        # chmod +x pbis-open-9.1.0.551.linux.x86_64.deb/install.sh
        echo "50"
        sleep 3
        echo "# Running Script ..."
        # sh pbis-open-9.1.0.551.linux.x86_64.deb/install.sh  >/dev/null 2>&1
        echo "65"
        sleep 3
        echo "# Domain Joining ..."
        domainjoin-cli join --disable ssh $dom $us $pw
        echo "75"
        sleep 3
        echo "# Almost Done ..."
        #echo $us
        cd /
        echo "80"
        sleep 3
        echo "# Removing Packages ..."
        rm -rf /tmp/pbis-open-9.1.0.551.linux.x86_64.*
        echo "85"
        sleep 3
        echo "# Installing ssh ..."
        apt-get install ssh -y >/dev/null 2>&1
        echo "90"
        sleep 3
        echo "# Domain Joined Sucessfully ..."
        echo "95"
        sleep 3
        echo "# Rebooting system ..."
        rsrt
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/progress.png" --progress \
            --title="Domain Joining" \
            --text="Domain Joining..." \
            --percentage=0 --auto-close
    if [[ $? == 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## Domain Join
domain() {
    ListType=$(zenity --window-icon ".ubuntusoftware/res/rage.png" --width=200 --height=170 --list --radiolist \
        --title 'Installation' \
        --text 'Select Option :' \
        --column 'Select' \
        --column 'Actions' TRUE "Join" FALSE "Remove")
    if [[ $? -eq 1 ]]; then
        # they pressed Cancel or closed the dialog window
        zenity --window-icon ".ubuntusoftware/res/error.png" --error --title="Declined" --width=200 \
            --text="installation Canceled   ❌"
        exit 1
    elif [ $ListType == "Join" ]; then
        # they selected the short radio button
        Flag="--Domain-Join"
        domainjoin
    elif [ $ListType == "Remove" ]; then
        # they selected the short radio button
        Flag="--Domain-Remove"
    else
        # they selected the long radio button
        Flag=""
    fi
}

## PHP Composer Installation
php_nl_in() {
    (
        echo "25"
        echo "# Downloading php-composer ..."
        sleep 3
        wget $php_comp_nl_url -P /tmp/ 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --window-icon ".ubuntusoftware/res/download.png" --progress --width=500 --auto-close --title="Downloading Php-composer..."
        echo "70"
        echo "# Installing Php-composer ..."
        sleep 3
        mkdir /usr/local/bin/composer >/dev/null 2>&1
        echo "60"
        mv /tmp/composer.phar /usr/local/bin/composer/ >/dev/null 2>&1
        echo "70":
        printf "alias composer='php /usr/local/bin/composer/composer.phar'" >>/etc/bash.bashrc
        echo "80"
        source /etc/bash.bashrc >/dev/null 2>&1
        echo "95"
        echo "# Installation Done ..."
        rm -rf /tmp/composer.phar >/dev/null 2>&1
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/php-com.png" --progress \
            --title="Installing PHP-Composer" \
            --text="Please wait ..." \
            --percentage=0 --auto-close
    echo "PHP-Composer $php_com_ver_ned $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "PHP-Composer" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=280 --height=100 --timeout 15 --title="PHP-Composer" --text "<span foreground='black' font='13'> PHP Composer Installed </span> \n\n<b><i>Version : $php_com_ver_ned  </i></b>✅"
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## PHP Composer Version List
php_comp_lst() {
    (
        url="https://github.com/composer/composer/releases/download/$choice/composer.phar"
        echo "25"
        echo "# Downloading php-composer ..."
        sleep 3
        wget $url -P /tmp/ 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --window-icon ".ubuntusoftware/res/download.png" --progress --width=500 --auto-close --title="Downloading Php-composer..."
        echo "70"
        echo "# Installing Php-composer ..."
        sleep 3
        mkdir /usr/local/bin/composer >/dev/null 2>&1
        echo "60"
        mv /tmp/composer.phar /usr/local/bin/composer/ >/dev/null 2>&1
        echo "70":
        #fusn=$(ls -t /home | awk 'NR==1 {print $1}')
        printf "alias composer='php /usr/local/bin/composer/composer.phar'" >>/etc/bash.bashrc
        echo "80"
        source /etc/bash.bashrc >/dev/null 2>&1
        echo "95"
        echo "# Installation Done ..."
        rm -rf /tmp/composer.phar >/dev/null 2>&1
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/php-com.png" --progress \
            --title="Installing PHP-Composer" \
            --text="Please wait ..." \
            --percentage=0 --auto-close
    echo "PHP-Composer $choice $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "PHP-Composer" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=280 --height=100 --timeout 15 --title="PHP-Composer" --text "<span foreground='black' font='13'> PHP Composer Installed  </span> \n\n<b><i>Version : $choice  </i></b>✅"
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## PHP Composer Installation Version Entry
php_comp_nl() {
    php_com_ver_ned=$(zenity --window-icon ".ubuntusoftware/res/php-com.png" --entry --width=200 --title "PHP-Composer" --text "PHP-Composer" --text="Enter Correct Version : ")
    php_comp_nl_url="https://github.com/composer/composer/releases/download/$php_com_ver_ned/composer.phar"
    # echo "$lan_nl_url"
    if curl --output /dev/null --silent --head --fail "$php_comp_nl_url"; then
        php_nl_in
    else
        zenity --window-icon ".ubuntusoftware/res/error.png" --error --width=250 --title="PHP-Composer Error" --text "<span foreground='black' font='13'> Incorrect Version !</span>"
    fi
}

## PHP Composer Installation Latest
php_comp() {
    lst_ph=$(curl -s https://github.com/composer/composer/tags | grep "/composer/composer/releases/tag/" | grep "<a href=" | sed 's|.*/||' | sed 's/.$//' | sed 's/.$//' | sort -Vr)
    choices=()
    mode="true"
    for name in $lst_ph; do
        choices=("${choices[@]}" "$mode" "$name")
        mode="false"
    done
    choice=$(zenity --window-icon ".ubuntusoftware/res/php-com.png" --width=300 --height=380 \
        --list \
        --separator="$IFS" \
        --radiolist \
        --text="Select Versions:" \
        --column "Select" \
        --column "Versions" \
        "${choices[@]}" \
        False "Version Not Listed Here")
    if [[ $? -eq 1 ]]; then
        # they pressed Cancel or closed the dialog window
        zenity --window-icon ".ubuntusoftware/res/error.png" --error --title="Declined" --width=200 \
            --text="installation Canceled   ❌"
        ins_del
        exit 1
    fi
    if [[ $choice == *"Version Not Listed Here"* ]]; then
        php_comp_nl
    elif [[ $choice == *"$choice"* ]]; then
        php_comp_lst
    else
        zenity --window-icon ".ubuntusoftware/res/error.png" --error --width=250 --title="PHP-Composer Error" --text "<span foreground='black' font='13'>Incorrect Selections !</span>"
    fi
}

## Checking PHP Composer Is Installed
php_comp_chk() {
    file="/usr/bin/php"
    # file1="/usr/local/bin/node"
    if [[ ! -e "$file" ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="<span foreground='black' font='13'>PHP is not installed  ❌</span>"
    else
        php_comp
    fi
}

## Lando INstallation Latest
lan_las() {
    (
        echo "25"
        echo "# Getting Data from lando ..."
        sleep 3
        lan_lat=$(curl -s https://github.com/lando/lando/tags | grep "/lando/lando/releases/tag/v" | grep "<a href=" | sed 's|.*/lando||' | sed 's/.$//' | sed 's/.$//' | sed 's|.*">||' | awk -v FS='</a>' '{print $1}' | awk 'NR==1 {print $1}')
        selver=$(echo "lando-x64-$lan_lat.deb")
        url="https://github.com/lando/lando/releases/download/$lan_lat/$selver"
        echo "50"
        echo "# Downloading Lando ..."
        sleep 3
        wget $url -P /tmp/ 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --window-icon ".ubuntusoftware/res/download.png" --progress --width=500 --auto-close --title="Downloading Lando..."
        echo "70"
        echo "# Installing Lando ..."
        sleep 3
        dpkg -i --ignore-depends=docker-ce /tmp/$selver >/dev/null 2>&1
        echo "95"
        echo "# Installation Done ..."
        sleep 3
        rm -rf /tmp/$selver
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/lando.png" --progress \
            --title="Installing Lando" \
            --text="Please Wait ..." \
            --percentage=0 --auto-close
    LAN_VER=$(dpkg -s lando | grep "Version:" | awk '{print $2}')
    echo "Lando $LAN_VER $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Lando" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=200 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'> Lando Installed </span>\n\n<b><i>Version : $LAN_VER   </i></b>✅"
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## Lando Version Entry Installation
lan_nl() {
    ver_ned=$(zenity --window-icon ".ubuntusoftware/res/lando.png" --entry --width=200 --title "Lando" --text "Lando" --text="Enter Correct Version : ")
    selver=$(echo "lando-x64-v$ver_ned.deb")
    lan_nl_url="https://github.com/lando/lando/releases/download/v$ver_ned/$selver"
    # echo "$lan_nl_url"
    if curl --output /dev/null --silent --head --fail "$lan_nl_url"; then
        lan_nl_in
    else
        zenity --window-icon ".ubuntusoftware/res/error.png" --error --width=250 --title="Lando Error" --text "<span foreground='black' font='13'> Incorrect Version !</span>"
    fi
}

## Lando Download And Installation
lan_nl_in() {
    (
        echo "50"
        echo "# Downloading Lando ..."
        sleep 3
        wget $lan_nl_url -P /tmp/ 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --window-icon ".ubuntusoftware/res/download.png" --progress --width=500 --auto-close --title="Downloading Lando..."
        echo "70"
        echo "# Installing Lando ..."
        sleep 3
        dpkg -i --ignore-depends=docker-ce /tmp/$selver >/dev/null 2>&1
        echo "95"
        echo "# Installation Done ..."
        sleep 3
        rm -rf /tmp/$selver
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/lando.png" --progress \
            --title="Installing Lando" \
            --text="Please Wait ..." \
            --percentage=0 --auto-close
    LAN_VER=$(dpkg -s lando | grep "Version:" | awk '{print $2}')
    echo "Lando $LAN_VER $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Lando" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=200 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'> Lando Installed </span>\n\n<b><i>Version :  $LAN_VER   </i></b>✅"
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## Lando Specific Version Installation
lan_spc_l() {
    (
        selver=$(echo "lando-x64-$choice.deb")
        url="https://github.com/lando/lando/releases/download/$choice/$selver"
        echo "50"
        echo "# Downloading Lando ..."
        sleep 3
        wget $url -P /tmp/ 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --window-icon ".ubuntusoftware/res/download.png" --progress --width=500 --auto-close --title="Downloading Lando..."
        echo "70"
        echo "# Installing Lando ..."
        sleep 3
        dpkg -i --ignore-depends=docker-ce /tmp/$selver >/dev/null 2>&1
        echo "95"
        echo "# Installation Done ..."
        sleep 3
        rm -rf /tmp/$selver
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/lando.png" --progress \
            --title="Installing Lando" \
            --text="Please Wait ..." \
            --percentage=0 --auto-close
    LAN_VER=$(dpkg -s lando | grep "Version:" | awk '{print $2}')
    echo "Lando $LAN_VER $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Lando" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=200 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'> Lando Installed </span>\n\n<b><i>Version :  $LAN_VER   </i></b>✅"
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## Lando Version List
lan_spc() {
    lst_l=$(curl -s https://github.com/lando/lando/tags | grep "/lando/lando/releases/tag/v" | grep "<a href=" | sed 's|.*/lando||' | sed 's/.$//' | sed 's/.$//' | sed 's|.*">||' | awk -v FS='</a>' '{print $1}')
    choices=()
    mode="true"
    for name in $lst_l; do
        choices=("${choices[@]}" "$mode" "$name")
        mode="false"
    done
    choice=$(zenity --window-icon ".ubuntusoftware/res/lando.png" --width=300 --height=380 \
        --list \
        --separator="$IFS" \
        --radiolist \
        --text="Select Versions:" \
        --column "Select" \
        --column "Versions" \
        "${choices[@]}" \
        False "Version Not Listed Here")
    if [[ $? -eq 1 ]]; then
        # they pressed Cancel or closed the dialog window
        zenity --window-icon ".ubuntusoftware/res/error.png" --error --title="Declined" --width=200 \
            --text="installation Canceled   ❌"
        ins_del
        exit 1
    fi
    if [[ $choice == *"Version Not Listed Here"* ]]; then
        lan_nl
    else
        lan_spc_l
    fi
}

## Lando Remove
lan_rm() {
    (
        echo "30"
        echo "# Removing Lando ..."
        sleep 3
        dpkg -P lando >/dev/null 2>&1
        echo "95"
        echo "# Removed Lando ..."
        sleep 3
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/lando.png" --progress \
            --title="Removing Lando" \
            --text="Lando..." \
            --percentage=0 --auto-close
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## Checking Lando Want To Remove
lan_rm_chk() {
    GIT_VER=$(dpkg -s lando | grep Version: | awk -F '-' '{print $1}' | awk '{print $2}')
    zenity --window-icon ".ubuntusoftware/res/done.png" --question --title="Lando Installation" --width=290 --text="<span foreground='black' font='13'> Lando v$GIT_VER is already installed   ✅</span>\n\n<b><i>Do you want to remove it ?</i></b>"
    if [ $? = 0 ]; then
        lan_rm
        lan
    fi
}

## Checking Lando Is Exist
lan_chk() {
    pkgs='lando'
    if dpkg -s $pkgs >/dev/null 2>&1; then
        lan_rm_chk
    else
        lan
    fi
}

## Lando Installation
lan() {
    lan_sel=$(zenity --window-icon ".ubuntusoftware/res/lando.png" --width=170 --height=170 --list --radiolist \
        --title 'Lando Installation' \
        --text 'Select Version to install:' \
        --column 'Select' \
        --column 'Actions' TRUE "Latest" FALSE "Specific")

    if [[ $? -eq 1 ]]; then
        # they pressed Cancel or closed the dialog window
        zenity --window-icon ".ubuntusoftware/res/error.png" --error --title="Declined" --width=200 \
            --text="installation Canceled   ❌"
        exit 1
    elif [[ $lan_sel == "Latest" ]]; then
        # they selected the short radio button
        Flag="--Lando-Latest"
        lan_las
    elif [[ $lan_sel == "Specific" ]]; then
        # they selected the short radio button
        Flag="--Lando-Specific"
        lan_spc
    fi
}

## NodeJS Remove
nj_rm() {
    (
        echo "30"
        echo "# Removing NodeJs ..."
        sleep 3
        apt-get purge --auto-remove nodejs -y >/dev/null 2>&1
        echo "50"
        echo "# Removing Related File ..."
        sleep 3
        rm -rf /etc/apt/sources.list.d/nodesource.list
        echo "95"
        echo "# Removed NodeJs ..."
        sleep 3
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/nodejs.png" --progress \
            --title="Removing NodeJs" \
            --text="NodeJs..." \
            --percentage=0 --auto-close
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## NPM Remove Files
npm_bichk() {
    (
        file="/usr/local/bin/npm"
        file1="/usr/local/bin/node"
        if [[ -e "$file" || -e $file1 ]]; then
            echo "30"
            echo "# Removing NodeJs ..."
            sleep 3
            rm -rf /usr/local/lib/node_modules &>/dev/null
            rm -rf /usr/local/share/man/man1/node* &>/dev/null
            rm -rf /usr/local/lib/dtrace/node.d &>/dev/null
            rm -rf ~/.npm &>/dev/null
            echo "50"
            echo "# Removing Related File ..."
            sleep 3
            rm -rf ~/.node-gyp &>/dev/null
            rm -rf /opt/local/bin/node &>/dev/null
            rm -rf opt/local/include/node &>/dev/null
            rm -rf /opt/local/lib/node_modules &>/dev/null
            echo "70"
            echo "# Removing Related File ..."
            sleep 3
            rm -rf /usr/local/lib/node* &>/dev/null
            rm -rf /usr/local/include/node* &>/dev/null
            rm -rf /usr/local/bin/node* &>/dev/null
            echo "95"
            echo "# Removed NodeJs ..."
            sleep 3
        fi
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/nodejs.png" --progress \
            --title="Removing NodeJs" \
            --text="NodeJs..." \
            --percentage=0 --auto-close
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## NPM Installation
npm_in() {
    zenity --window-icon ".ubuntusoftware/res/question.png" --question --width=350 --text="<span foreground='black' font='13'> Did you want to install  <b>NPM Latest Version</b> ?</span>" --ok-label="Yes" --cancel-label="No"
    if [ $? = 0 ]; then
        # echo "yes"
        npm install -g npm@latest &>/dev/null
    fi
}

## Checking NodeJS Is Installed
nj_chk() {
    pkgs='nodejs'
    if dpkg -s $pkgs >/dev/null 2>&1; then
        nj_rm
    fi
}

## NodeJS Installation
nj_in() {
    (
        echo "25"
        echo "# Getting Data from NodeJs ..."
        sleep 3
        ver=$(curl -s "https://nodejs.org/dist/latest-$choice/" | grep "node" | awk -F 'node-' '{print $2 FS "/"}' | grep "v" | awk -F "/" '{print $1}' | grep "linux-x64.tar.gz" | awk -F "-" '{print $1}')
        selver=$(echo "node-$ver-linux-x64.tar.gz")
        url="https://nodejs.org/dist/latest-$choice/$selver"
        curl -o /tmp/$selver $url 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\n#Download Speed\:\2/' | zenity --width=500 --window-icon ".ubuntusoftware/res/download.png" --progress --auto-close --title "Downloading NodeJs"
        echo "70"
        echo "# Installing NodeJs ..."
        sleep 3
        tar -C /usr/local --strip-components 1 -xzf /tmp/$selver >/dev/null
        echo "80"
        echo "# Installing NPM ..."
        sleep 3
        npm_in
        echo "95"
        echo "# Installation Done ..."
        sleep 3
        rm -rvf /tmp/$selver
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/nodejs.png" --progress \
            --title="Installing NodeJs" \
            --text="Please Wait ..." \
            --percentage=0 --auto-close
    NODE_VER=$(node -v)
    NPM_VER=$(npm -v)
    echo "NodeJs $NODE_VER $tmstamp" >>$log_file
    echo "NPM $NPM_VER $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "NodeJs" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "NPM" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=250 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'> NodeJS </span>\n\n<b><i>Version : $NODE_VER   </i></b>✅\n\n<span foreground='black' font='13'> Npm </span>\n\n<b><i>Version : $NPM_VER  </i></b>✅"
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## NodeJS Version List
nj_list() {
    cl
    nj_chk
    npm_bichk
    lst=$(curl -s "https://nodejs.org/dist/" | grep "latest" | awk -F 'latest-' '{print $2 FS "/"}' | grep "v" | awk -F "/" '{print $1}' | sort -Vr)
    choices=()
    mode="true"
    for name in $lst; do
        choices=("${choices[@]}" "$mode" "$name")
        mode="false"
    done
    choice=$(zenity --window-icon ".ubuntusoftware/res/nodejs.png" --width=300 --height=380 \
        --title 'NodeJS Versions' \
        --list \
        --separator="$IFS" \
        --radiolist \
        --text="Select Versions:" \
        --column "Select" \
        --column "Versions" \
        "${choices[@]}")
    if [[ $? -eq 1 ]]; then
        # they pressed Cancel or closed the dialog window
        zenity --window-icon ".ubuntusoftware/res/error.png" --error --title="Declined" --width=200 \
            --text="Canceled installation"
        ins_del
        exit 1
    elif [[ $choice == *"$choice"* ]]; then
        nj_in
    else
        zenity --window-icon ".ubuntusoftware/res/error.png" --error --width=250 --title="NodeJS Error" --text "<b>Incorrect Selections !</b>"
    fi
}

## NodeJS Version Entry
nj_entr() {
    njent=$(zenity --entry \
        --title="NodeJs Version" \
        --text="Enter Specific Version:")
    if [[ $? -eq 1 ]]; then
        # they pressed Cancel or closed the dialog window
        zenity --window-icon ".ubuntusoftware/res/error.png" --error --title="Declined" --width=200 --timeout 15 \
            --text="installation Canceled   ❌"
        exit 1
    elif [[ -z "$njent" ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --error --title="Error" --width=200 \
            --text="Invalid Version"
        nj
    else
        nj_entr_ins
    fi
}

## NodeJS Installation
nj_entr_pack() {
    (
        echo "10"
        echo "# Checking Dependency ..."
        sleep 3
        cl
        echo "20"
        echo "# Checking Package Is Exist ..."
        sleep 3
        nj_chk
        echo "40"
        echo "# Removing Exist Node ..."
        sleep 3
        npm_bichk
        echo "60"
        echo "# Getting Data from NodeJs ..."
        sleep 3
        nfn="node-v$njent-linux-x64.tar.gz"
        pack_down="$nj_url/$nfn"
        curl -o /tmp/$nfn $pack_down 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\n#Download Speed\:\2/' | zenity --width=500 --window-icon ".ubuntusoftware/res/download.png" --progress --auto-close --title "Downloading NodeJs v$njent"
        echo "70"
        echo "# Installing NodeJs v$njent ..."
        sleep 3
        tar -C /usr/local --strip-components 1 -xzf /tmp/$nfn >/dev/null
        echo "80"
        echo "# Installing NPM ..."
        sleep 3
        npm_in
        echo "95"
        echo "# Installation Done ..."
        sleep 3
        rm -rvf /tmp/$nfn
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/nodejs.png" --progress \
            --title="Installing NodeJs" \
            --text="Please Wait ..." \
            --percentage=0 --auto-close
    NODE_VER=$(node -v)
    NPM_VER=$(npm -v)
    echo "NodeJs $NODE_VER $tmstamp" >>$log_file
    echo "NPM $NPM_VER $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "NodeJs" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "NPM" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=250 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'> NodeJS </span>\n\n<b><i>Version : $NODE_VER   </i></b>✅\n\n<span foreground='black' font='13'> Npm </span>\n\n<b><i>Version : $NPM_VER  </i></b>✅"
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## NodeJS Entry Installation
nj_entr_ins() {
    nj_url="https://nodejs.org/download/release/v$njent"
    if curl --head --silent --fail "$nj_url" >/dev/null 2>&1; then
        nj_entr_pack
    else
        zenity --window-icon ".ubuntusoftware/res/error.png" --error --title="NodeJs" --width=200 \
            --text="Invalid Version"
        nj_entr
    fi
}

## NodeJS Main
nj() {
    nj_sel=$(zenity --window-icon ".ubuntusoftware/res/nodejs.png" --width=250 --height=170 --list --radiolist \
        --title 'NodeJs Installation' \
        --text '<b>Install From:</b>' \
        --column 'Select' \
        --column 'Actions' TRUE "NodeJs Release List" FALSE "Specific Version")

    if [[ $? -eq 1 ]]; then
        # they pressed Cancel or closed the dialog window
        zenity --window-icon ".ubuntusoftware/res/error.png" --error --title="Declined" --width=200 \
            --text="installation Canceled   ❌"
        exit 1
    elif [[ $nj_sel == "NodeJs Release List" ]]; then
        # they selected the short radio button
        Flag="--Nodejs-Latest"
        nj_list
    elif [[ $nj_sel == "Specific Version" ]]; then
        # they selected the short radio button
        Flag="--NodeJs-Specific"
        nj_entr
    fi
}

## Git Remove
git_rm() {
    (
        echo "50"
        echo "# Removing Git ..."
        apt-get purge git -y >/dev/null 2>&1
        echo "95"
        echo "# Removed ! ..."
        sleep 5
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/git.png" --progress \
            --title="Removing Git" \
            --text="Removing Git..." \
            --percentage=0 --auto-close
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="UnInstalltion Canceled   ❌ "
        # ins_del
    fi
}

## GitK Remove
gitk_rm() {
    (
        echo "50"
        echo "# Removing Gitk ..."
        apt-get purge gitk -y >/dev/null 2>&1
        echo "95"
        echo "# Removed ! ..."
        sleep 5
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/git.png" --progress \
            --title="Removing Gitk" \
            --text="Removing Gitk..." \
            --percentage=0 --auto-close
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="UnInstalltion Canceled   ❌ "
        # ins_del
    fi
}

## Git Want To Remove ?
git_rm_cf() {
    GIT_VER=$(git --version | awk '{print $3}')
    zenity --window-icon ".ubuntusoftware/res/done.png" --question --title="Git Installation" --width=290 --text="<span foreground='black' font='13'> Git v$GIT_VER is already installed   ✅</span>\n\n<b><i>Do you want to remove it ?</i></b>"
    if [ $? = 0 ]; then
        git_rm
        gt_ans="Yes"
    else
        gt_ans="No"
    fi
}

## GitK Want To Remove ?
gitk_rm_cf() {
    GITK_VER=$(dpkg -s git | grep "Version: 1:" | awk '{print $2}' | awk -F ':' '{print $2}' | awk -F '-' '{print $1}')
    zenity --window-icon ".ubuntusoftware/res/done.png" --question --title="Git Installation" --width=290 --text="<span foreground='black' font='13'> Gitk v$GITK_VER is already installed   ✅</span>\n\n<b><i>Do you want to remove it ?</i></b>"
    if [ $? = 0 ]; then
        gitk_rm
        gtk_ans="Yes"
    else
        gtk_ans="No"
    fi
}

## Checking Git Is Installed
git_chk() {
    pkgs='git'
    if dpkg -s $pkgs >/dev/null 2>&1; then
        git_rm_cf
    else
        gt_ans="Yes"
    fi
}

## Checking GitK Is Installed
gitk_chk() {
    pkgs='gitk'
    if dpkg -s $pkgs2 >/dev/null 2>&1; then
        gitk_rm_cf
    else
        gtk_ans="Yes"
    fi
}

## Git Installation
git_ins() {
    (
        echo "15"
        echo "# Getting Ready for installation ..."
        sleep 5
        echo "50"
        echo "# Installing Git ..."
        apt-get install git-all -y >/dev/null 2>&1
        echo "90"
        echo "# Almost Done ..."
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/git.png" --progress \
            --title="Installing Git" \
            --text="Installing Git..." \
            --percentage=0 --auto-close
    GIT_VER=$(git --version | awk '{printf $3}')
    echo "Git $GIT_VER $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Git" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=250 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'> Git Installed </span>\n\n<b><i>Version : $GIT_VER   </i></b>✅"
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌ "
        # ins_del
    fi
}

## GitK Installation
gitk_ins() {
    (
        echo "15"
        echo "# Getting Ready for installation ..."
        sleep 5
        echo "50"
        echo "# Installing Gitk ..."
        apt-get install gitk -y >/dev/null 2>&1
        echo "90"
        echo "# Almost Done ..."
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/git.png" --progress \
            --title="Installing Gitk" \
            --text="Installing Gitk..." \
            --percentage=0 --auto-close
    GITK_VER=$(dpkg -s git | grep "Version: 1:" | awk '{print $2}' | awk -F ':' '{print $2}' | awk -F '-' '{print $1}')
    echo "Gitk $GITK_VER $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Gitk" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=180 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'> GitK Installed </span>\n\n<b><i>Version :  $GITK_VER   </i></b>✅ "
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌ "
        # ins_del
    fi
}

## Git Main
git_main() {
    git_chk
    if [[ $gt_ans == "Yes" ]]; then
        git_ins
    fi
    gitk_chk
    if [[ $gtk_ans == "Yes" ]]; then
        gitk_ins
    fi
}

## Gulp Dependency Checking
gulp_dep_chk() {
    pkgs='npm'
    if ! $pkgs -v >/dev/null 2>&1; then
        zenity --question --title="Installation" --width=290 --text="<span foreground='black' font='13'>Gulp Dependency !</span>\n\n<b><i>Do you want to install it ?</i></b>"
        if [ $? = 0 ]; then
            nj
            gulp_versel
        elif [ $? = 1 ]; then
            exit
        else
            zenity --width=200 --error \
                --text="installation Canceled   ❌"
            exit
        fi
    else
        gulp_versel
    fi
}

## Gulp Version Select
gulp_versel() {
    gulp_sel=$(zenity --window-icon ".ubuntusoftware/res/gulp.png" --width=170 --height=170 --list --radiolist \
        --title 'Gulp Installation' \
        --text 'Select Version to install:' \
        --column 'Select' \
        --column 'Actions' TRUE "Latest" FALSE "Specific")

    if [[ $? -eq 1 ]]; then
        # they pressed Cancel or closed the dialog window
        zenity --window-icon ".ubuntusoftware/res/error.png" --error --title="Declined" --width=200 \
            --text="installation Canceled   ❌"
        exit 1
    elif [[ $gulp_sel == "Latest" ]]; then
        # they selected the short radio button
        Flag="--Gulp-Latest"
        gulp_las
    elif [[ $gulp_sel == "Specific" ]]; then
        # they selected the short radio button
        Flag="--Gulp-Specific"
        gulp_entr
    fi
}

## Gulp Latest Version
gulp_las() {
    (
        echo "15"
        echo "# Preparing ... "
        sleep 3
        echo "35"
        echo "# Installing Gulp ... "
        npm install -g gulp-cli >/dev/null 2>&1
        echo "55"
        echo "# All Most Done ... "
        sleep 3
        echo "90"
        echo "# Installed ... "
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/gulp.png" --progress \
            --title="Gulp" \
            --text="Installing Gulp ..." \
            --percentage=0 --auto-close
    gulp_ver
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## Gulp Version Entery
gulp_entr() {
    gulp_ent=$(zenity --entry \
        --title="Gulp Version" \
        --text="Enter Specific Version:")
    if [[ $? -eq 1 ]]; then
        # they pressed Cancel or closed the dialog window
        zenity --window-icon ".ubuntusoftware/res/error.png" --error --title="Declined" --width=200 --timeout 15 \
            --text="installation Canceled   ❌"
        exit 1
    elif [[ -z "$gulp_ent" ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --error --title="Error" --width=200 \
            --text="Invalid Version"
    else
        gulp_spc
    fi
}
## Gulp Specific Version
gulp_spc() {
    (
        echo "15"
        echo "# Preparing ... "
        sleep 3
        echo "35"
        echo "# Installing Gulp ... "
        npm install -g gulp-cli@$gulp_ent >/dev/null 2>&1
        echo "55"
        echo "# All Most Done ... "
        sleep 3
        echo "90"
        echo "# Installed ... "
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/gulp.png" --progress \
            --title="Gulp" \
            --text="Installing Gulp ..." \
            --percentage=0 --auto-close
    gulp_ver
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## Gulp Version
gulp_ver() {
    gulp_vers=$(gulp -v | grep -o "version.*" | awk 'NR==1{print $2}')
    if [[ ! -z "$gulp_vers" ]]; then
        echo "Gulp $gulp_vers $tmstamp" >>$log_file
        awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Gulp" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
        zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=250 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'> Gulp Is Installed ! </span>\n\n<b><i>Version : $gulp_vers   </i></b>✅"
    else
        zenity --width=300 --error \
            --title="Gulp Error" \
            --text="<span foreground='black' font='13'>Gulp not installed, Please check log file !</span>\n\n<b>'/var/log/ubuntusoftware/error-xxx.log'</b>"
    fi
}
## Gulp Remove
gulp_rm() {
    (
        echo "15"
        echo "# Preparing ... "
        sleep 3
        echo "35"
        echo "# Removing Gulp ... "
        npm uninstall -g gulp-cli >/dev/null 2>&1
        echo "55"
        echo "# All Most Done ... "
        sleep 3
        echo "90"
        echo "# Removed Gulp ... "
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/gulp.png" --progress \
            --title="Removing Gulp" \
            --text="Gulp ..." \
            --percentage=0 --auto-close
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

# Gulp Check Version
gulp_chk() {
    gulp_vers=$(gulp -v | grep -o "version.*" | awk 'NR==1{print $2}')
    if [[ -z "$gulp_vers" ]]; then
        gulp_dep_chk
    else
        gulp_rm_cf
    fi
}
# Gulp Remove Version
gulp_rm_cf() {
    zenity --window-icon ".ubuntusoftware/res/done.png" --question --title="Git Installation" --width=350 --text "<span foreground='black' font='13'> Gulp Is Already Installed ! </span>\n\n<b>Did you need to change this version : $gulp_vers </b>❓ "
    if [ $? = 0 ]; then
        gulp_rm
        gulp_dep_chk
        gulp_ans="Yes"
    else
        gulp_ans="No"
    fi
}

## Checking MYSQL Is Installed
MYS_CHK() {
    pkgs='mariadb-server'
    if ! dpkg -s $pkgs >/dev/null 2>&1; then
        MY_INS
    else
        MYSQL_VER=$(mysql --version | awk '{print $5}')
        echo "Mysql $MYSQL_VER $tmstamp" >>$log_file
        awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Mysql" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
        zenity --window-icon ".ubuntusoftware/res/mariadb.png" --info --timeout 10 --width=250 --height=100 --title="MariaDB" --text "<span foreground='black' font='13'> MariaDB Already Installed </span>\n\n<b><i>Version : $MYSQL_VER </i></b>✅"
    fi
}

## MYSQL Installation
MY_INS() {
    (
        echo "25"
        echo "# Updating Packages ..."
        apt-get autoremove -y >/dev/null
        dpkg --configure -a
        apt-get update -y >/dev/null
        echo "35"
        echo "# Installing MariaDB ..."
        apt-get install -y $pkgs >/dev/null
        echo "50"
        echo "# Configuring MariaDB ..."
        sleep 3
        db_root_password=root
        cat <<EOF | mysql_secure_installation
y
y
$db_root_password
$db_root_password
y
y
y
y
y
EOF
        echo "75"
        echo "# Changing Permission ..."
        MYSQL=$(which mysql)
        Q1="grant all privileges on *.* to 'root'@'%' identified by 'root';"
        Q2="FLUSH PRIVILEGES;"
        SQL="${Q1}${Q2}"
        MYSQL_VER=$(mysql --version | awk '{print $5}')
        echo "85"
        echo "# Almost Done ..."
        $MYSQL -uroot -p$db_root_password -e "$SQL"
        echo "100"
        echo "# MariaDb has been Installed ..."
        MYSQL_VER=$(mysql --version | awk '{print $5}')
        echo "Mysql $MYSQL_VER $tmstamp" >>$log_file
        awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Mysql" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
        zenity --window-icon ".ubuntusoftware/res/mariadb.png" --info --timeout 10 --width=250 --height=100 --title="MariaDB" --text "<span foreground='black' font='13'> MariaDB Installed </span>\n\n<b><i>Version : $MYSQL_VER </i></b>✅"
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/mariadb.png" --progress \
            --title="Installing MariaDB" \
            --text="Installing MariaDB..." \
            --percentage=0 --auto-close
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="UnInstalltion Canceled   ❌ "
        ins_del
    fi
}

## MYSQL Remove
MY_RMV() {
    (
        pkgs='mariadb-server'
        if ! dpkg -s $pkgs >/dev/null 2>&1; then
            zenity --window-icon ".ubuntusoftware/res/mariadb.png" --info --timeout 10 --width=250 --height=100 --title="MariaDB" --text "<span foreground='black' font='13'> ⚠️  No MariaDB Found  ⚠️ </span>"
        else
            echo "10"
            echo "Killing Process"
            killall -KILL mysql mysqld_safe mysqld
            echo "25"
            echo "# Removing Mysql ..."
            dpkg --configure -a
            echo "30"
            service mysql stop
            echo "35"
            dpkg --configure -a
            apt-get remove "mysql*" -y >/dev/null
            echo "40"
            apt-get --yes autoremove --purge >/dev/null
            apt-get autoclean >/dev/null
            echo "45"
            deluser --remove-home mysql >/dev/null
            delgroup mysql >/dev/null
            rm -rf /etc/apparmor.d/abstractions/mysql /etc/apparmor.d/cache/usr.sbin.mysqld /etc/mysql /var/lib/mysql /var/log/mysql* /var/log/upstart/mysql.log* /var/run/mysql
            echo "50"
            echo "# Removing MariaDB-Server ..."
            sleep 3
            apt-get --purge remove "mariadb*" -y >/dev/null
            echo "75"
            echo "# Removing Files ..."
            sleep 3
            rm -rf /var/lib/mysql/ >/dev/null
            echo "100"
            echo "# MariaDB Removed ... "
            sleep 5
        fi
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/mariadb.png" --progress \
            --title="Removing MariaDB" \
            --text="Removing MariaDB..." \
            --percentage=0 --auto-close
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="UnInstalltion Canceled   ❌ "
        ins_del
    fi
}

## MYSQL Main
MYS() {
    ListType=$(zenity --window-icon ".ubuntusoftware/res/mariadb.png" --width=400 --height=200 --list --radiolist \
        --title 'Installation' \
        --text 'Select Software to install:' \
        --column 'Select' \
        --column 'Actions' TRUE "Install" FALSE "Remove")
    if [[ $ListType == "Install" ]]; then
        # they selected the short radio button
        MYS_CHK
    elif [[ $ListType == "Remove" ]]; then
        # they selected the short radio button
        MY_RMV
    else
        zenity --window-icon ".ubuntusoftware/res/error.png" --error --title="Declined" --width=200 \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## Stopping Apache Services
apache_stop() {
    if [ -x "$(command -v apache2)" ]; then
        systemctl stop apache2.service >/dev/null
        systemctl disable apache2.service >/dev/null
    fi
}

## Stopping Nginx Services
nginx_stop() {
    if [ -x "$(command -v nginx)" ]; then
        systemctl stop nginx.service >/dev/null
        systemctl disable nginx.service >/dev/null
    fi
}

## Stopping PHP-56 Services
php5_6_stop() {
    if [ -x "$(command -v php5.6)" ]; then
        systemctl stop php5.6-fpm.service >/dev/null
        systemctl disable php5.6-fpm.service >/dev/null
    fi
}

## Stopping PHP-70 Services
php7_0_stop() {
    if [ -x "$(command -v php7.0)" ]; then
        systemctl stop php7.0-fpm.service >/dev/null
        systemctl disable php7.0-fpm.service >/dev/null
    fi
}

## Stopping PHP-71 Services
php7_1_stop() {
    if [ -x "$(command -v php7.1)" ]; then
        systemctl stop php7.1-fpm.service >/dev/null
        systemctl disable php7.1-fpm.service >/dev/null
    fi
}

## Stopping PHP-72 Services
php7_2_stop() {
    if [ -x "$(command -v php7.2)" ]; then
        systemctl stop php7.2-fpm.service >/dev/null
        systemctl disable php7.2-fpm.service >/dev/null
    fi
}

## Stopping PHP-73 Services
php7_3_stop() {
    if [ -x "$(command -v php7.3)" ]; then
        systemctl stop php7.3-fpm.service >/dev/null
        systemctl disable php7.3-fpm.service >/dev/null
    fi
}

## Stopping PHP-74 Services
php7_4_stop() {
    if [ -x "$(command -v php7.4)" ]; then
        systemctl stop php7.4-fpm.service >/dev/null
        systemctl disable php7.4-fpm.service >/dev/null
    fi
}

## Stopping PHP-80 Services
php8_0_stop() {
    if [ -x "$(command -v php8.0)" ]; then
        systemctl stop php8.0-fpm.service >/dev/null
        systemctl disable php8.0-fpm.service >/dev/null
    fi
}

## PHP-56 Installation
php5_6() {
    (
        echo "5"
        echo "# Checking Repository ..."
        sleep 3
        pkgs='software-properties-common'
        if ! dpkg -s $pkgs >/dev/null 2>&1; then
            echo "15"
            echo "# Installing Repository ..."
            apt-get install software-properties-common -y >/dev/null
            echo "20"
            echo "# Adding Packages ..."
            add-apt-repository ppa:ondrej/php -y >/dev/null
            echo "50"
            echo "# Updating ..."
            apt-get update -y >/dev/null
            echo "60"
            echo "# Installing PHP 5.6 ..."
            apt-get install php5.6-{common,cli,fpm} -y >/dev/null
            echo "70"
            echo "# Installing PHP 5.6 extensions ..."
            apt-get install php5.6-{curl,intl,mysql,readline,xml,gd,imap,intl,ldap,mbstring,mysql,sqlite3,pspell,soap,tidy,xml,xsl,zip,bcmath} -y >/dev/null
            echo "75"
            echo "# Configuring ..."
            sleep 3
            sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9002/g' /etc/php/5.6/fpm/pool.d/www.conf
            echo "90"
            echo "# Almost Done ..."
            sudo update-rc.d php5.6-fpm defaults >/dev/null
            echo "100"
            echo "# PHP 5.6 Installed ..."
        else
            echo "20"
            echo "# Adding Packages ..."
            add-apt-repository ppa:ondrej/php -y >/dev/null
            echo "50"
            echo "# Updating ..."
            apt-get update -y >/dev/null
            echo "60"
            echo "# Installing PHP 5.6 ..."
            apt-get install php5.6-{common,cli,fpm} -y >/dev/null
            echo "70"
            echo "# Installing PHP 5.6 extensions ..."
            apt-get install php5.6-{curl,intl,mysql,readline,xml,gd,imap,intl,ldap,mbstring,mysql,sqlite3,pspell,soap,tidy,xml,xsl,zip,bcmath} -y >/dev/null
            echo "75"
            echo "# Configuring ..."
            sleep 3
            sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9002/g' /etc/php/5.6/fpm/pool.d/www.conf
            echo "90"
            echo "# Almost Done ..."
            sudo update-rc.d php5.6-fpm defaults >/dev/null
            echo "100"
            echo "# PHP 5.6 Installed ..."
        fi
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/php.png" --progress \
            --title="PHP 5.6 Installing" \
            --text="PHP 5.6 Installing..." \
            --percentage=0 --auto-close
    echo "PHP-5.6 5.6 $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "PHP-5.6" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=200 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'>PHP Installed !</span>\n\n<b><i>Version :   5.6   </i></b>✅"
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌ "
    fi
}

## PHP-70 Installation
php7_0() {
    (
        echo "5"
        echo "# Checking Repository ..."
        sleep 3
        pkgs='software-properties-common'
        if ! dpkg -s $pkgs >/dev/null 2>&1; then
            echo "15"
            echo "# Installing Repository ..."
            apt-get install software-properties-common -y >/dev/null
            echo "20"
            echo "# Adding Packages ..."
            add-apt-repository ppa:ondrej/php -y >/dev/null
            echo "50"
            echo "# Updating ..."
            apt-get update -y >/dev/null
            echo "60"
            echo "# Installing PHP 7.0 ..."
            apt-get install php7.0-{common,cli,fpm} -y >/dev/null
            echo "70"
            echo "# Installing PHP 7.0 extensions ..."
            apt-get install php7.0-{curl,intl,mysql,readline,xml,gd,imap,intl,ldap,mbstring,mysql,sqlite3,pspell,soap,tidy,xml,xsl,zip,bcmath} -y >/dev/null
            echo "75"
            echo "# Configuring ..."
            sleep 3
            sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9001/g' /etc/php/7.0/fpm/pool.d/www.conf
            echo "90"
            echo "# Almost Done ..."
            sudo update-rc.d php7.0-fpm defaults >/dev/null
            echo "100"
            echo "# PHP 7.0 Installed ..."
        else
            echo "20"
            echo "# Adding Packages ..."
            add-apt-repository ppa:ondrej/php -y >/dev/null
            echo "50"
            echo "# Updating ..."
            apt-get update -y >/dev/null
            echo "60"
            echo "# Installing PHP 7.0 ..."
            apt-get install php7.0-{common,cli,fpm} -y >/dev/null
            echo "70"
            echo "# Installing PHP 7.0 extensions ..."
            apt-get install php7.0-{curl,intl,mysql,readline,xml,gd,imap,intl,ldap,mbstring,mysql,sqlite3,pspell,soap,tidy,xml,xsl,zip,bcmath} -y >/dev/null
            echo "75"
            echo "# Configuring ..."
            sleep 3
            sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9001/g' /etc/php/7.0/fpm/pool.d/www.conf
            echo "90"
            echo "# Almost Done ..."
            sleep 3
            sudo update-rc.d php7.0-fpm defaults >/dev/null
            echo "100"
            echo "# PHP 7.0 Installed ..."
        fi
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/php.png" --progress \
            --title="PHP 7.0 Installing" \
            --text="PHP 7.0 Installing..." \
            --percentage=0 --auto-close
    echo "PHP-7.0 7.0 $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "PHP-7.0" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=200 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'>PHP Installed !</span>\n\n<b><i>Version :   7.0   </i></b>✅"
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌ "
    fi
}

## PHP-71 Installation
php7_1() {
    (
        echo "5"
        echo "# Checking Repository ..."
        sleep 3
        pkgs='software-properties-common'
        if ! dpkg -s $pkgs >/dev/null 2>&1; then
            echo "15"
            echo "# Installing Repository ..."
            apt-get install software-properties-common -y >/dev/null
            echo "20"
            echo "# Adding Packages ..."
            add-apt-repository ppa:ondrej/php -y >/dev/null
            echo "50"
            echo "# Updating ..."
            apt-get update -y >/dev/null
            echo "60"
            echo "# Installing PHP 7.1 ..."
            apt-get install php7.1-{common,cli,fpm} -y >/dev/null
            echo "70"
            echo "# Installing PHP 7.1 extensions ..."
            apt-get install php7.1-{curl,intl,mysql,readline,xml,gd,imap,intl,ldap,mbstring,mysql,sqlite3,pspell,soap,tidy,xml,xsl,zip,bcmath} -y >/dev/null
            echo "75"
            echo "# Configuring ..."
            sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9000/g' /etc/php/7.1/fpm/pool.d/www.conf
            echo "90"
            echo "# Almost Done ..."
            sleep 3
            sudo update-rc.d php7.1-fpm defaults >/dev/null
            echo "100"
            echo "# PHP 7.1 Installed ..."
        else
            echo "20"
            echo "# Adding Packages ..."
            add-apt-repository ppa:ondrej/php -y >/dev/null
            echo "50"
            echo "# Updating ..."
            apt-get update -y >/dev/null
            echo "60"
            echo "# Installing PHP 7.1 ..."
            apt-get install php7.1-{common,cli,fpm} -y >/dev/null
            echo "70"
            echo "# Installing PHP 7.1 extensions ..."
            apt-get install php7.1-{curl,intl,mysql,readline,xml,gd,imap,intl,ldap,mbstring,mysql,sqlite3,pspell,soap,tidy,xml,xsl,zip,bcmath} -y >/dev/null
            echo "75"
            echo "# Configuring ..."
            sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9000/g' /etc/php/7.1/fpm/pool.d/www.conf
            echo "90"
            echo "# Almost Done ..."
            sleep 3
            sudo update-rc.d php7.1-fpm defaults >/dev/null
            echo "100"
            echo "# PHP 7.1 Installed ..."
        fi
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/php.png" --progress \
            --title="PHP 7.1 Installing" \
            --text="PHP 7.1 Installing..." \
            --percentage=0 --auto-close
    echo "PHP-7.1 7.1 $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "PHP-7.1" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=200 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'>PHP Installed !</span>\n\n<b><i>Version :   7.1   </i></b>✅"
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌ "
    fi
}

## PHP-72 Installation
php7_2() {
    (
        echo "5"
        echo "# Checking Repository ..."
        sleep 3
        pkgs='software-properties-common'
        if ! dpkg -s $pkgs >/dev/null 2>&1; then
            echo "15"
            echo "# Installing Repository ..."
            apt-get install software-properties-common -y >/dev/null
            echo "20"
            echo "# Adding Packages ..."
            add-apt-repository ppa:ondrej/php -y >/dev/null
            echo "50"
            echo "# Updating ..."
            apt-get update -y >/dev/null
            echo "60"
            echo "# Installing PHP 7.2 ..."
            apt-get install php7.2-{common,cli,fpm} -y >/dev/null
            echo "70"
            echo "# Installing PHP 7.2 extensions ..."
            apt-get install php7.2-{curl,intl,mysql,readline,xml,gd,imap,intl,ldap,mbstring,mysql,sqlite3,pspell,soap,tidy,xml,xsl,zip,bcmath} -y >/dev/null
            echo "75"
            echo "# Configuring ..."
            sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9003/g' /etc/php/7.2/fpm/pool.d/www.conf
            echo "90"
            echo "# Almost Done ..."
            sleep 3
            sudo update-rc.d php7.2-fpm defaults >/dev/null
            echo "100"
            echo "# PHP 7.2 Installed ..."
        else
            echo "20"
            echo "# Adding Packages ..."
            add-apt-repository ppa:ondrej/php -y >/dev/null
            echo "50"
            echo "# Updating ..."
            apt-get update -y >/dev/null
            echo "60"
            echo "# Installing PHP 7.2 ..."
            apt-get install php7.2-{common,cli,fpm} -y >/dev/null
            echo "70"
            echo "# Installing PHP 7.2 extensions ..."
            apt-get install php7.2-{curl,intl,mysql,readline,xml,gd,imap,intl,ldap,mbstring,mysql,sqlite3,pspell,soap,tidy,xml,xsl,zip,bcmath} -y >/dev/null
            echo "75"
            echo "# Configuring ..."
            sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9003/g' /etc/php/7.2/fpm/pool.d/www.conf
            echo "90"
            echo "# Almost Done ..."
            sleep 3
            sudo update-rc.d php7.2-fpm defaults >/dev/null
            echo "100"
            echo "# PHP 7.2 Installed ..."
        fi
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/php.png" --progress \
            --title="PHP 7.2 Installing" \
            --text="PHP 7.2 Installing..." \
            --percentage=0 --auto-close
    echo "PHP-7.2 7.2 $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "PHP-7.2" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=200 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'>PHP Installed !</span>\n\n<b><i>Version :   7.2   </i></b>✅"
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌ "
    fi
}

## PHP-73 Installation
php7_3() {
    (
        echo "5"
        echo "# Checking Repository ..."
        sleep 3
        pkgs='software-properties-common'
        if ! dpkg -s $pkgs >/dev/null 2>&1; then
            echo "15"
            echo "# Installing Repository ..."
            apt-get install software-properties-common -y >/dev/null
            echo "20"
            echo "# Adding Packages ..."
            add-apt-repository ppa:ondrej/php -y >/dev/null
            echo "50"
            echo "# Updating ..."
            apt-get update -y >/dev/null
            echo "60"
            echo "# Installing PHP 7.3 ..."
            apt-get install php7.3-{common,cli,fpm} -y >/dev/null
            echo "70"
            echo "# Installing PHP 7.3 extensions ..."
            apt-get install php7.3-{curl,intl,mysql,readline,xml,gd,imap,intl,ldap,mbstring,mysql,sqlite3,pspell,soap,tidy,xml,xsl,zip,bcmath} -y >/dev/null
            echo "75"
            echo "# Configuring ..."
            sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9003/g' /etc/php/7.3/fpm/pool.d/www.conf
            echo "90"
            echo "# Almost Done ..."
            sleep 3
            sudo update-rc.d php7.3-fpm defaults >/dev/null
            echo "100"
            echo "# PHP 7.3 Installed ..."
        else
            echo "20"
            echo "# Adding Packages ..."
            add-apt-repository ppa:ondrej/php -y >/dev/null
            echo "50"
            echo "# Updating ..."
            apt-get update -y >/dev/null
            echo "60"
            echo "# Installing PHP 7.3 ..."
            apt-get install php7.3-{common,cli,fpm} -y >/dev/null
            echo "70"
            echo "# Installing PHP 7.3 extensions ..."
            apt-get install php7.3-{curl,intl,mysql,readline,xml,gd,imap,intl,ldap,mbstring,mysql,sqlite3,pspell,soap,tidy,xml,xsl,zip,bcmath} -y >/dev/null
            echo "75"
            echo "# Configuring ..."
            sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9003/g' /etc/php/7.3/fpm/pool.d/www.conf
            echo "90"
            echo "# Almost Done ..."
            sleep 3
            sudo update-rc.d php7.3-fpm defaults >/dev/null
            echo "100"
            echo "# PHP 7.3 Installed ..."
        fi
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/php.png" --progress \
            --title="PHP 7.3 Installing" \
            --text="PHP 7.3 Installing..." \
            --percentage=0 --auto-close
    echo "PHP-7.3 7.3 $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "PHP-7.3" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=200 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'>PHP Installed !</span>\n\n<b><i>Version :   7.3   </i></b>✅"
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌ "
    fi
}

## PHP-74 Installation
php7_4() {
    (
        echo "5"
        echo "# Checking Repository ..."
        sleep 3
        pkgs='software-properties-common'
        if ! dpkg -s $pkgs >/dev/null 2>&1; then
            echo "15"
            echo "# Installing Repository ..."
            apt-get install software-properties-common -y >/dev/null
            echo "20"
            echo "# Adding Packages ..."
            add-apt-repository ppa:ondrej/php -y >/dev/null
            echo "35"
            echo "# Downloading Modules ..."
            wget -O /tmp/libonig4_6.7.0-1_amd64.deb http://archive.ubuntu.com/ubuntu/pool/universe/libo/libonig/libonig4_6.7.0-1_amd64.deb 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --window-icon ".ubuntusoftware/res/download.png" --progress --width=500 --auto-close --title="Downloading Modules ..."
            echo "45"
            echo "# Installing Modules ..."
            dpkg -i /tmp/libonig4_6.7.0-1_amd64.deb >/dev/null 2>&1
            echo "50"
            echo "# Updating ..."
            apt-get update -y >/dev/null
            echo "60"
            echo "# Installing PHP 7.4 ..."
            apt-get install php7.4 php7.4-{common,cli,fpm} -y >/dev/null
            echo "70"
            echo "# Installing PHP 7.4 extensions ..."
            apt-get install php7.4-{curl,intl,mysql,readline,xml,gd,imap,intl,ldap,mbstring,mysql,sqlite3,pspell,soap,tidy,xml,xsl,zip,bcmath} -y >/dev/null
            echo "75"
            echo "# Configuring ..."
            sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9003/g' /etc/php/7.4/fpm/pool.d/www.conf
            echo "90"
            echo "# Almost Done ..."
            sleep 3
            sudo update-rc.d php7.4-fpm defaults >/dev/null
            echo "100"
            rm -rf /tmp/libonig4_6.7.0-1_amd64.deb
            echo "# PHP 7.4 Installed ..."
            sleep 3
        else
            echo "20"
            echo "# Adding Packages ..."
            add-apt-repository ppa:ondrej/php -y >/dev/null
            echo "35"
            echo "# Downloading Modules ..."
            wget -O /tmp/libonig4_6.7.0-1_amd64.deb http://archive.ubuntu.com/ubuntu/pool/universe/libo/libonig/libonig4_6.7.0-1_amd64.deb 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --window-icon ".ubuntusoftware/res/download.png" --progress --width=500 --auto-close --title="Downloading Modules ..."
            echo "45"
            echo "# Installing Modules ..."
            dpkg -i /tmp/libonig4_6.7.0-1_amd64.deb >/dev/null 2>&1
            echo "50"
            echo "# Updating ..."
            apt-get update -y >/dev/null
            echo "60"
            echo "# Installing PHP 7.4 ..."
            apt-get install php7.4 php7.4-{common,cli,fpm} -y >/dev/null
            echo "68"
            echo "# Installing PHP 7.4 extensions ..."
            apt-get install php7.4-{curl,intl,mysql,readline,xml,gd,imap,intl,ldap,mbstring,mysql,sqlite3,pspell,soap,tidy,xml,xsl,zip,bcmath} -y >/dev/null
            echo "75"
            echo "# Configuring ..."
            sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9003/g' /etc/php/7.4/fpm/pool.d/www.conf
            echo "90"
            echo "# Almost Done ..."
            sleep 3
            sudo update-rc.d php7.4-fpm defaults >/dev/null
            echo "100"
            rm -rf /tmp/libonig4_6.7.0-1_amd64.deb
            echo "# PHP 7.4 Installed ..."
            sleep 3
        fi
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/php.png" --progress \
            --title="PHP 7.4 Installing" \
            --text="PHP 7.4 Installing..." \
            --percentage=0 --auto-close
    echo "PHP-7.4 7.4 $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "PHP-7.4" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=200 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'>PHP Installed !</span>\n\n<b><i>Version :   7.4   </i></b>✅"
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌ "
    fi
}

## PHP-80 Installation
php8_0() {
    (
        echo "5"
        echo "# Checking Repository ..."
        sleep 3
        pkgs='software-properties-common'
        if ! dpkg -s $pkgs >/dev/null 2>&1; then
            echo "15"
            echo "# Installing Repository ..."
            apt-get install software-properties-common -y >/dev/null
            echo "20"
            echo "# Adding Packages ..."
            add-apt-repository ppa:ondrej/php -y >/dev/null
            echo "50"
            echo "# Updating ..."
            apt-get update -y >/dev/null
            echo "60"
            echo "# Installing PHP 8.0 ..."
            apt-get install php8.0-common php8.0-cli php8.0-fpm -y >/dev/null
            echo "70"
            echo "# Installing PHP 8.0 extensions ..."
            apt-get install php8.0-{curl,intl,mysql,readline,xml,gd,imap,intl,ldap,mbstring,mysql,sqlite3,pspell,soap,tidy,xml,xsl,zip,bcmath} -y >/dev/null
            # apt-get install php8.0-fpm php8.0-bcmath php8.0-cli php8.0-common php8.0-curl php8.0-gd php8.0-intl php8.0-imap php8.0-json php8.0-ldap php8.0-mbstring php8.0-mysql php8.0-sqlite3  php8.0-pspell php8.0-soap php8.0-tidy php8.0-xml php8.0-xsl php8.0-zip -y >/dev/null
            echo "75"
            echo "# Configuring ..."
            sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9004/g' /etc/php/8.0/fpm/pool.d/www.conf
            echo "90"
            echo "# Almost Done ..."
            sleep 3
            sudo update-rc.d php8.0-fpm defaults >/dev/null
            echo "100"
            echo "# PHP 8.0 Installed ..."
            sleep 3
        else
            echo "20"
            echo "# Adding Packages ..."
            add-apt-repository ppa:ondrej/php -y >/dev/null
            echo "50"
            echo "# Updating ..."
            apt-get update -y >/dev/null
            echo "60"
            echo "# Installing PHP 8.0 ..."
            apt-get install php8.0-common php8.0-cli php8.0-fpm -y >/dev/null
            echo "70"
            echo "# Installing PHP 8.0 extensions ..."
            apt-get install php8.0-{bcmath,curl,gd,intl,imap,ldap,mbstring,mysql,sqlite3,pspell,soap,tidy,xml,xsl,zip} -y >/dev/null
            echo "75"
            echo "# Configuring ..."
            sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9004/g' /etc/php/8.0/fpm/pool.d/www.conf
            echo "90"
            echo "# Almost Done ..."
            sleep 3
            sudo update-rc.d php8.0-fpm defaults >/dev/null
            echo "100"
            echo "# PHP 8.0 Installed ..."
            sleep 3
        fi
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/php.png" --progress \
            --title="PHP 8.0 Installing" \
            --text="PHP 8.0 Installing..." \
            --percentage=0 --auto-close
    echo "PHP-8.0 8.0 $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "PHP-8.0" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --width=200 --height=100 --timeout 15 --title="Version Details" --text "<span foreground='black' font='13'>PHP Installed !</span>\n\n<b><i>Version :  8.0   </i></b>✅"
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌ "
        ins_del
    fi
}

## PHP Versions
php_ver() {

    php_sel=$(
        zenity --window-icon ".ubuntusoftware/res/php.png" --width=150 --height=280 --checklist --list \
            --title='PHP' \
            --text="<b>Select PHP Version To Install :</b>" \
            --column="Select" --column="Version List" \
            " " "8.0" \
            " " "7.4" \
            " " "7.3" \
            " " "7.2" \
            " " "7.1" \
            " " "7.0" \
            " " "5.6"
    )

    if [[ $? -eq 1 ]]; then
        # they pressed Cancel or closed the dialog window
        zenity --window-icon ".ubuntusoftware/res/error.png" --error --title="Declined" --width=200 \
            --text="installation Canceled   ❌ "
        # ins_del
        exit 1
    fi
    if [[ -z "$php_sel" ]]; then
        # they selected the short radio button
        zenity --width=200 --height=25 --timeout 15 --error \
            --text="Select Any One To Install ⚠️"
        # ins
    fi
    if [[ $php_sel == *"8.0"* ]]; then
        if ! [ -x "$(command -v php8.0)" ]; then
            php8_0
        else
            zenity --window-icon ".ubuntusoftware/res/done.png" --info --timeout 10 --width=190 --height=100 --title="Version Details" --text "<span foreground='black' font='13'> PHP Already Installed</span>\n\n<b><i>Version :   8.0   </i></b>✅"
        fi
    fi
    if [[ $php_sel == *"7.4"* ]]; then
        if ! [ -x "$(command -v php7.4)" ]; then
            php7_4
        else
            zenity --window-icon ".ubuntusoftware/res/done.png" --info --timeout 10 --width=190 --height=100 --title="Version Details" --text "<span foreground='black' font='13'> PHP Already Installed</span>\n\n<b><i>Version :   7.4   </i></b>✅"
        fi
    fi
    if [[ $php_sel == *"7.3"* ]]; then
        if ! [ -x "$(command -v php7.3)" ]; then
            php7_3
        else
            zenity --window-icon ".ubuntusoftware/res/done.png" --info --timeout 10 --width=190 --height=100 --title="Version Details" --text "<span foreground='black' font='13'> PHP Already Installed</span>\n\n<b><i>Version :   7.3   </i></b>✅"
        fi
    fi
    if [[ $php_sel == *"7.2"* ]]; then
        if ! [ -x "$(command -v php7.2)" ]; then
            php7_2
        else
            zenity --window-icon ".ubuntusoftware/res/done.png" --info --timeout 10 --width=190 --height=100 --title="Version Details" --text "<span foreground='black' font='13'> PHP Already Installed</span>\n\n<b><i>Version :   7.2   </i></b>✅"
        fi
    fi
    if [[ $php_sel == *"7.1"* ]]; then
        if ! [ -x "$(command -v php7.1)" ]; then
            php7_1
        else
            zenity --window-icon ".ubuntusoftware/res/done.png" --info --timeout 10 --width=190 --height=100 --title="Version Details" --text "<span foreground='black' font='13'> PHP Already Installed</span>\n\n<b><i>Version :   7.1   </i></b>✅"
        fi
    fi
    if [[ $php_sel == *"7.0"* ]]; then
        if ! [ -x "$(command -v php7.0)" ]; then
            php7_0
        else
            zenity --window-icon ".ubuntusoftware/res/done.png" --info --timeout 10 --width=190 --height=100 --title="Version Details" --text "<span foreground='black' font='13'> PHP Already Installed</span>\n\n<b><i>Version :   7.0   </i></b>✅"
        fi
    fi
    if [[ $php_sel == *"5.6"* ]]; then
        if ! [ -x "$(command -v php5.6)" ]; then
            php5_6
        else
            zenity --window-icon ".ubuntusoftware/res/done.png" --info --timeout 10 --width=190 --height=100 --title="Version Details" --text "<span foreground='black' font='13'> PHP Already Installed</span>\n\n<b><i>Version :   5.6   </i></b>✅"
        fi
    fi
}

## Nginx Installation
NG() {
    (
        echo "10"
        echo "# Checking Package ..."
        sleep 3
        pkgs='nginx'
        if ! dpkg -s $pkgs >/dev/null 2>&1; then
            echo "30"
            echo "# Updating Package ..."
            cd /tmp/
            wget http://nginx.org/keys/nginx_signing.key >/dev/null
            apt-key add nginx_signing.key >/dev/null
            sh -c "echo 'deb http://nginx.org/packages/ubuntu/ '$(lsb_release -cs)' nginx' > /etc/apt/sources.list.d/Nginx.list" >/dev/null
            apt-get update -y >/dev/null
            echo "50"
            echo "# Installing Nginx ..."
            apt-get install -y $pkgs >/dev/null
            echo "80"
            echo "Setting up ..."
            sleep 3
            update-rc.d nginx defaults >/dev/null
            rm -rf /tmp/nginx*
            echo "100"
            echo "# Nginx Installed ..."
            sleep 3
        fi
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/nginx.png" --progress \
            --title="Installing Nginx" \
            --text="Installing Nginx..." \
            --percentage=0 --auto-close
    echo "Nginx NA $tmstamp" >>$log_file
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Nginx" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    zenity --window-icon ".ubuntusoftware/res/done.png" --info --timeout 10 --width=200 --no-wrap --title="NginX" --text "<span foreground='black' font='13'>Nginx Installed Sucessfully  ✅  </span>"
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## Docker-Compose Installation
DOCK_COMP() {
    (
        echo "10"
        echo "# Checking Package ..."
        echo "25"
        echo "# Downloading Docker-compose ..."
        curl -s -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose >/dev/null
        chmod +x /usr/local/bin/docker-compose
        echo "50"
        echo "# Installing Docker-compose ..."
        apt-get install -y docker-compose >/dev/null
        echo "100"
        echo "# Docker-compose Installed ..."
        sleep 3
        DOCOM_VER=$(docker-compose --version | awk '{print $3}' | sed 's/.$//')
        echo "Docker-Comp $DOCOM_VER $tmstamp" >>$log_file
        awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Docker-Comp" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/docker.png" --progress \
            --title="Installing Docker-Compose-" \
            --text="Installing Docker-Compose..." \
            --percentage=0 --auto-close
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="installation Canceled   ❌"
        ins_del
    fi
}

## Checking Docker-Compose
DOCK_CHK() {
    if [ ! -x "$(command -v docker)" ]; then
        DOCK_IN
        DOCK_CHK
    elif [ ! -x "$(command -v docker-compose)" ]; then
        DOCK_COMP
        DOCK_CHK
    else
        DOCOM_VER=$(docker-compose --version | awk '{print $3}' | sed 's/.$//')
        DOCK_VER=$(docker --version | awk '{print $3}' | sed 's/.$//')
        zenity --window-icon ".ubuntusoftware/res/done.png" --info --timeout 15 --width=300 --height=100 --title="Docker Installation" --text "<span foreground='black' font='13'>Docker Already Installed</span>\n\n<b><i>Docker Version : $DOCK_VER  ✅\n\nDocker-compose Version : $DOCOM_VER  ✅</i></b>"
    fi
}

## Docker Installation
DOCK_IN() {
    # optr=`zenity --list --radiolist --column="Select" --column="Actions" $(ls  /home/local/RAGE/  | awk -F'\n' '{print NR, $1}')`
    if [[ $? -eq 0 ]]; then
        (
            per='RAGE\'
            domain='RAGE\domain^users'
            path=' /home/local/RAGE/'"$optr"
            echo "10"
            echo "# Collecting Data ..."
            sleep 5
            # cd $path
            #"Permission Changing"
            echo "23"
            echo "# Changing Project Permission ..."
            sleep 5
            # chown -R $per''$optr:$domain projects/
            echo "32"
            echo "# Installing dependencies ..."
            apt-get install \
                apt-transport-https \
                ca-certificates \
                curl \
                gnupg-agent \
                software-properties-common -y >/dev/null
            echo "40"
            echo "# Adding Docker Repo ..."
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - >/dev/null
            add-apt-repository \
                "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) \
            stable" -y >/dev/null
            echo "53"
            echo "# Updating and Installing Docker-ce ..."
            apt-get update -y >/dev/null
            apt-get install docker-ce docker-ce-cli containerd.io -y >/dev/null
            systemctl start docker
            systemctl enable docker
            echo "60"
            echo "# Stoping PHP 5.6 ..."
            php5_6_stop
            echo "65"
            echo "# Stoping PHP 7.0 ..."
            php7_0_stop
            echo "70"
            echo "# Stoping PHP 7.1 ..."
            php7_1_stop
            echo "73"
            echo "# Stoping PHP 7.2 ..."
            php7_2_stop
            echo "75"
            echo "# Stoping PHP 7.3 ..."
            php7_3_stop
            echo "78"
            echo "# Stoping PHP 7.4 ..."
            php7_4_stop
            echo "78"
            echo "# Stoping PHP 8.0 ..."
            php8_0_stop
            echo "85"
            echo "# Stoping Nginx ..."
            nginx_stop
            echo "90"
            echo "# Stoping Apache ..."
            apache_stop
            echo "95"
            echo "# Configuring Docker Setup ..."
            sudo sed -i -e 's/SocketMode=.*/SocketMode=0666/g' /lib/systemd/system/docker.socket
            systemctl daemon-reload
            systemctl stop docker.socket
            systemctl start docker.socket
            echo "100"
            sleep 5
            echo "# Docker Installed ..."
            DOCK_VER=$(docker --version | awk '{print $3}' | sed 's/.$//')
            echo "Docker $DOCK_VER $tmstamp" >>$log_file
            awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}' $log_file | grep "Docker" | grep "$tmstamp" >>"$reprt_path/report-$dstamp.txt"
        ) |
            zenity --width=500 --window-icon ".ubuntusoftware/res/docker.png" --progress \
                --title="Docker Installation" \
                --text="Docker Installation..." \
                --percentage=0 --auto-close
        if [[ $? -eq 1 ]]; then
            zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
                --text="installation Canceled   ❌"
            ins_del
        fi
    else
        zenity --window-icon ".ubuntusoftware/res/error.png" --error --title="Declined" --width=200 \
            --text="Installtaion Canceled "
        ins_del
        exit 1
    fi
}

## Resource Icon
RES() {
    (
        echo "25"
        echo "# Checking ..."
        RES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/.ubuntusoftware/res"
        if [[ ! -e "$RES_DIR" ]]; then
            curl -sLJo res.zip https://github.com/AShuuu-Technoid/Ubuntu_Software_Installtion/archive/refs/heads/res.zip >/dev/null
            mkdir -p .ubuntusoftware/res >/dev/null
            unzip res.zip >/dev/null
            mv Ubuntu_Software_Installtion-res/* .ubuntusoftware/res >/dev/null
            rm -rf Ubuntu_Software_Installtion-res >/dev/null
            rm -rf res.zip >/dev/null
        fi
        echo "50"
        echo "# Preparing ..."

        ENC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/.ubuntusoftware/.encry.enc"
        PJ_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/.ubuntusoftware/.pjenc.enc"
        if [[ ! -e "$ENC_DIR" ]] && [[ ! -e "$PJ_DIR" ]]; then
            curl -sLJo enc.zip https://github.com/AShuuu-Technoid/Ubuntu_Software_Installtion/archive/refs/heads/enc.zip >/dev/null
            # mkdir .r >/dev/null
            unzip enc.zip >/dev/null
            mv Ubuntu_Software_Installtion-enc/.encry.enc .ubuntusoftware/ >/dev/null
            mv Ubuntu_Software_Installtion-enc/.pjenc.enc .ubuntusoftware/ >/dev/null
            rm -rf Ubuntu_Software_Installtion-enc >/dev/null
            rm -rf enc.zip >/dev/null
        fi
        echo "90"
        echo "# Almost Done ..."
    ) |
        zenity --width=500 --window-icon ".ubuntusoftware/res/rage.png" --progress \
            --title="Preparing ..." \
            --text="Please Wait ..." \
            --percentage=0 --auto-close
    if [[ $? -eq 1 ]]; then
        zenity --window-icon ".ubuntusoftware/res/error.png" --width=200 --error \
            --text="UnInstalltion Canceled   ❌ "
        ins_del
    fi
}

## Sub Menu
ins() {
    ListType_1=$(
        zenity --window-icon ".ubuntusoftware/res/rage.png" --width=350 --height=420 --checklist --list \
            --title='Ubuntu Software Installation' \
            --ok-label="Next" \
            --text="<b>Select <span foreground='red'> Utilities Software </span>To Install :</b>\n <span foreground='red' font='10'>⚠️ NOTE : Don't select Domain-join in multi selection. ⚠️ </span>" \
            --column="Select" --column="Software List" \
            " " "Domain-Join" \
            " " "Chrome" \
            " " "Firefox" \
            " " "VS Code" \
            " " "FileZilla" \
            " " "Meld" \
            " " "Pinta" \
            " " "Screen Time" \
            " " "Rage Kiosk" \
            " " "Symantec Endpoint Protection" \
            " " "Forticlient (IITM)" \
            " " "OpenVPN (Rage VPN)"
    )
    if [[ $? -eq 1 ]]; then
        # they pressed Cancel or closed the dialog window
        zenity --window-icon ".ubuntusoftware/res/error.png" --error --title="Declined" --width=200 \
            --text="installation Canceled   ❌"
        ins_del
        exit 1
    fi
    ListType_2=$(
        zenity --window-icon ".ubuntusoftware/res/rage.png" --width=350 --height=420 --checklist --list \
            --title='Ubuntu Software Installation' \
            --ok-label="Install" \
            --text="<b>Select <span foreground='red'>Developer Software </span>To Install :</b>" \
            --column="Select" --column="Software List" \
            " " "Gulp" \
            " " "NodeJs" \
            " " "MariaDB" \
            " " "Redis-tools" \
            " " "Mysql-Client" \
            " " "PHP" \
            " " "Composer (php)" \
            " " "Nginx" \
            " " "Docker" \
            " " "Project Setup" \
            " " "Lando" \
            " " "Git" \
            " " "Postman"
    )
    if [[ $? -eq 1 ]]; then
        # they pressed Cancel or closed the dialog window
        zenity --window-icon ".ubuntusoftware/res/error.png" --error --title="Declined" --width=200 \
            --text="installation Canceled   ❌"
        ins_del
        exit 1
    fi
    if [[ -z "$ListType_1" ]] && [[ -z "$ListType_2" ]]; then
        # they selected the short radio button
        zenity --width=200 --height=25 --timeout 15 --error \
            --text="Select Any One To Install ⚠️"
        ins
    fi
    if [[ $ListType_1 == *"Domain-Join"* ]]; then
        # they selected the short radio button
        Flag="--Domain-Join"
        domain
    fi
    if [[ $ListType_1 == *"Chrome"* ]]; then
        # they selected the short radio button
        Flag="--Chrome"
        chrm_chk
    fi
    if [[ $ListType_1 == *"Firefox"* ]]; then
        # they selected the short radio button
        Flag="--Firefox"
        firefx_chk
    fi
    if [[ $ListType_1 == *"VS Code"* ]]; then
        # they selected the short radio button
        Flag="--VS Code"
        vscd_chk
    fi
    if [[ $ListType_1 == *"FileZilla"* ]]; then
        # they selected the short radio button
        Flag="--FLZ"
        filezilla_chk
    fi
    if [[ $ListType_1 == *"Meld"* ]]; then
        # they selected the short radio button
        Flag="--Meld"
        mld_chk
    fi
    if [[ $ListType_1 == *"Pinta"* ]]; then
        # they selected the short radio button
        Flag="--Pinta"
        pinta_chk
    fi
    if [[ $ListType_1 == *"Screen Time"* ]]; then
        # they selected the short radio button
        Flag="--Screen Time"
        scntm_chk
    fi
    if [[ $ListType_1 == *"Rage Kiosk"* ]]; then
        # they selected the short radio button
        Flag="--Rage Kiosk"
        rgk_ins_chk
    fi
    if [[ $ListType_1 == *"Symantec Endpoint Protection"* ]]; then
        # they selected the short radio button
        Flag="--SEP"
        symc_chk
    fi
    if [[ $ListType_1 == *"Forticlient"* ]]; then
        # they selected the short radio button
        Flag="--Forticlient"
        vpn_chk
    fi
    if [[ $ListType_1 == *"OpenVPN"* ]]; then
        # they selected the short radio button
        Flag="--OpenVPN"
        opn_vpn
    fi

    ################## Phase - 2 #####################
    if [[ $ListType_2 == *"NodeJs"* ]]; then
        # they selected the short radio button
        Flag="--NodeJs"
        nj
    fi
    if [[ $ListType_2 == *"Gulp"* ]]; then
        # they selected the short radio button
        Flag="--Gulp"
        gulp_chk
    fi
    if [[ $ListType_2 == *"MariaDB"* ]]; then
        # they selected the short radio button
        Flag="--MariaDB"
        Mariadb
    fi
    if [[ $ListType_2 == *"Redis-tools"* ]]; then
        # they selected the short radio button
        Flag="--Redis-tools"
        redis_chk
    fi
    if [[ $ListType_2 == *"Mysql-Client"* ]]; then
        # they selected the short radio button
        Flag="--Mysql-Client"
        mysql_clt_chk
    fi
    if [[ $ListType_2 == *"PHP"* ]]; then
        # they selected the short radio button
        Flag="--PHP"
        php_ver
    fi
    if [[ $ListType_2 == *"Composer"* ]]; then
        # they selected the short radio button
        Flag="--Composer"
        php_comp_chk
    fi
    if [[ $ListType_2 == *"Nginx"* ]]; then
        # they selected the short radio button
        Flag="--Nginx"
        NG
    fi
    if [[ $ListType_2 == *"Docker"* ]]; then
        # they selected the short radio button
        Flag="--Docker"
        DOCK_CHK
    fi
    if [[ $ListType_2 == *"Project Setup"* ]]; then
        # they selected the short radio button
        Flag="--Project Setup"
        proj_finl
    fi
    if [[ $ListType_2 == *"Lando"* ]]; then
        # they selected the short radio button
        Flag="--Lando"
        lan_chk
    fi
    if [[ $ListType_2 == *"Git"* ]]; then
        # they selected the short radio button
        Flag="--Git"
        git_main
    fi
    if [[ $ListType_2 == *"Postman"* ]]; then
        # they selected the short radio button
        Flag="--PSM"
        postman_chk
    fi
}

## PHP Team Custom Menu
php_tm_custom() {
    # Chrome installtion
    chrm_chk
    # Firefox Installation
    firefx_chk
    # Vscode
    vscd_chk
    # Git
    git_main
    # Meld
    mld_chk
    # Filezilla
    filezilla_chk
    # Postman
    postman_chk
    # Docker
    DOCK_CHK
    # Lando
    lan_chk
    # lan
    # Mysql-client
    mysql_clt_chk
    # Redis
    redis_chk
    # Utilities tools
    tools_chk
    # Project Setup
    proj_finl
}

## Main Menu
main() {
    clear
    if [ $(whoami) != root ]; then
        zenity --width=350 --error \
            --text="Please Run This Scripts As <b>root</b> Or As <b>Sudo User</b>"
        exit
    else
        cl
        RES
        log
        apt_fix
        ListType=$(zenity --window-icon ".ubuntusoftware/res/rage.png" --width=250 --height=200 --list --radiolist \
            --title 'Rage Software' \
            --text 'Ubuntu Installation' \
            --column 'Select' \
            --ok-label="Next" \
            --column 'Actions' TRUE "PHP Team Custom" FALSE "Manual Installtion")
        if [[ $? -eq 1 ]]; then
            zenity --window-icon ".ubuntusoftware/res/error.png" --error --title="Declined" --width=200 \
                --text="installation Canceled   ❌"
            ins_del
            exit 1
        elif [[ $ListType == "PHP Team Custom" ]]; then
            php_tm_custom
        elif [[ $ListType == "Manual Installtion" ]]; then
            ins

        fi
    fi

}

## Run With Log Executing
main exec 2>> >(awk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0 }' >>"$LOG_FILE")

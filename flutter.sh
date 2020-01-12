#!/bin/bash

# 初始化记录项目pwd
projectDir=`pwd`

# 假如没有引用三方的flutter Plugin 设置false 即可
isPlugin=true

cd ${projectDir}
#
## 删除 fat-aar 引用
function delFatAarConfig() {
    if [[  ${isPlugin} == false  ]]; then
        echo '删除 fat-aar 引用........未配置三方插件'
    else :
        cd ${projectDir} # 回到项目
        echo '删除 fat-aar 引用 ... '
        sed -i '' '$d
            ' .android/settings.gradle
        sed -i '' '$d
            ' .android/Flutter/build.gradle
        sed -i '' '$d
            ' .android/Flutter/build.gradle
        sed -i '' '11 d
            ' .android/build.gradle
    fi
}

fat_aar_name="com.kezong:fat-aar"
fat_aar_version="1.2.8"

## 引入fat-aar
function addFatAArConfig() {
     if [[  ${isPlugin} == false  ]]; then
        echo '引入fat-aar 配置........未配置三方插件'
     else :
        cd ${projectDir} # 回到项目

        cp configs/setting_gradle_plugin.gradle .android/config/setting_gradle_plugin.gradle

        if [[ `grep -c 'setting_gradle_plugin.gradle' .android/settings.gradle` -eq '1' ]]; then
            echo ".android/settings.gradle 中 已存在 ！！！"
        else
            echo ".android/settings.gradle 中 不存在，去编辑"
            #插入
            sed -i '' '$a\
            apply from: "./config/setting_gradle_plugin.gradle"
            ' .android/settings.gradle
        fi

        if [[ $? -eq 0 ]]; then
            echo '.android/settings.gradle 中 脚本插入 fat-aar 成功 !!!'
        else
            echo '.android/settings.gradle 中 脚本插入 fat-aar 出错 !!!'
            exit 1
        fi

        if [[ `grep -c 'com.kezong:fat-aar' .android/build.gradle` -eq '1' ]]; then
            echo "${fat_aar_name}:${fat_aar_version} 已存在 ！！！"
        else
            echo "${fat_aar_name}:${fat_aar_version} 不存在，去添加"
            sed -i '' '10 a\
            classpath "com.kezong:fat-aar:1.2.8"
            ' .android/build.gradle
        fi

        # flutter/build.gradle 中添加fat-aar 依赖 和 dependencies_gradle_plugin
        if [[ `grep -c "com.kezong.fat-aar" .android/Flutter/build.gradle` -eq '1' ]]; then
            echo "Flutter/build.gradle 中 com.kezong:fat-aar 已存在 ！！！"
        else
            echo "Flutter/build.gradle 中 com.kezong:fat-aar 不存在，去添加"
            sed -i '' '$a\
            apply plugin: "com.kezong.fat-aar"
            ' .android/Flutter/build.gradle
        fi

        cp configs/dependencies_gradle_plugin.gradle .android/config/dependencies_gradle_plugin.gradle
        if [[ `grep -c 'dependencies_gradle_plugin' .android/Flutter/build.gradle` -eq '1' ]]; then
            echo "Flutter/build.gradle 中 dependencies_gradle_plugin.gradle 已存在 ！！！"
        else
            echo "Flutter/build.gradle 中 dependencies_gradle_plugin.gradle 不存在，去添加"
            sed -i '' '$a\
            apply from: "../config/dependencies_gradle_plugin.gradle"
            ' .android/Flutter/build.gradle
        fi
      fi
}


cmd=$1
echo "$0 $1 start"
function packageGet(){
    echo "#########################packages get#########################"
    flutter packages get
    if [[ $? -ne 0 ]]; then
       echo "packages get error"
    fi
}

function copyBuildGradle(){
    echo "#########################copy build.gradle#########################"
    cp configs/build.gradle .android/app/build.gradle
}

function flutterRun(){
    echo "#########################flutter run#########################"
    flutter run
}

function flutterClean() {
    echo "#########################flutter clean#########################"
    flutter clean
}

function createConfigDir() {
    if [[  -d '.android/config/' ]]; then
        echo '.android/config 文件夹已存在'
    else :
       mkdir .android/config
    fi
}

function buildApk() {
    cd ${projectDir}
    flutter build apk
    if [[ $? -eq 0 ]]; then
        echo '打包成aar 成功！！！'
    else
        echo '打包成aar 出错 !!!'
        exit 1
    fi
}


flutterClean
packageGet
copyBuildGradle
createConfigDir
addFatAArConfig
buildApk

cd ${projectDir}/.android/Flutter/src/main/
rm -rf assets
rm -rf lib
delFatAarConfig

echo '<<<<<<<<<<<<<<<<<<<<<<<<<< 打包flutter.aar结束 >>>>>>>>>>>>>>>>>>>>>>>>>'
echo "打包成功: ${projectDir}/.android/Flutter/build/outputs/aar/flutter-release.aar"


exit
#!/bin/bash

BRANCH=master

#iosdev_u4
LANG=en_US.UTF-8
PATH=/opt/local/bin:/opt/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin

PRJ_DEVELOP="$WORKSPACE/Project/$Branch/Develop"
BUILD_DIR="$WORKSPACE/Project/$Branch/Build"
UNITY_APP_DIR="/Applications/Unity/Unity.app/Contents/MacOS/Unity"
DEVELOP_BUNDLE_DIR="$PRJ_DEVELOP/Assets/AssetBundles"
DEVELOP_IOSBUNDLE_DIR="$DEVELOP_BUNDLE_DIR/iOS"
BUILD_BUNDLE_DIR="$BUILD_DIR/Assets/AssetBundles"
BUILD_IOSBUNDLE_DIR="$BUILD_BUNDLE_DIR/iOS"
VIDEO_DIR="AssetBundles/iOS/Videos"
STREAMVIDEO_DIR="StreamingAssets/Videos"
SHADER_DIR="Resources/Public/Shader"
SVN_DIR="/opt/subversion/bin/svn"
XCODE_BACKUP_ROOT_DIR="/Users/Frozen/Desktop/XCode_BackUp"

echo "分支：$Branch"

echo "环境：$Env"

echo "SDK: $SDK"

echo "plat: $plat"

echo "ServerVersion: $ServerVersion"

echo "usePush：$usePush"

echo "pushAppKey：$pushAppKey"

echo "pushIsRelease: $pushIsRelease"

echo "sign: $sign"

#1
echo "检查资源的依赖关系"
$UNITY_APP_DIR -projectPath $PRJ_DEVELOP -executeMethod BuildMenu.BuildAll -batchmode -quit || exit 1
#2
echo "打包assetbundles"
$UNITY_APP_DIR -projectPath $PRJ_DEVELOP -executeMethod AutoBuildAssetBundles.BuildAssetBundles -batchmode -quit
#3
echo "删除并拷贝assetbundles/video"
if [ ! -d "$PRJ_DEVELOP/Assets/$VIDEO_DIR" ]; then  
	mkdir $PRJ_DEVELOP/Assets/$VIDEO_DIR
fi
cd $PRJ_DEVELOP/Assets/$VIDEO_DIR
rm -R `ls *.mp4`
cp -RP $PRJ_DEVELOP/Assets/$STREAMVIDEO_DIR/*.mp4 $PRJ_DEVELOP/Assets/$VIDEO_DIR
#4
echo "删除build目录下的assetbundles并拷贝"
rm -R $BUILD_IOSBUNDLE_DIR
mkdir $BUILD_IOSBUNDLE_DIR
cp -R $DEVELOP_IOSBUNDLE_DIR/* $BUILD_IOSBUNDLE_DIR
#5
echo "copy projectsettings部分设置配置"
cp -R $PRJ_DEVELOP/ProjectSettings/TagManager.asset $BUILD_DIR/ProjectSettings/TagManager.asset
#6
echo "删除并拷贝build目录下code"
rm -R $BUILD_DIR/Assets/Code
rsync -aP --exclude="/Editor/" --exclude="/Refactory/Editor/" --exclude="/Refactory/EditorUtils/" $PRJ_DEVELOP/Assets/Code/* $BUILD_DIR/Assets/Code/
#7
echo "删除并拷贝build目录下shader"
rm -R $BUILD_DIR/Assets/$SHADER_DIR
rsync -aP $PRJ_DEVELOP/Assets/$SHADER_DIR/* $BUILD_DIR/Assets/$SHADER_DIR/
#8
echo "删除并拷贝build目录下plugin"
rm -R $BUILD_DIR/Assets/Plugins
rsync -aP $PRJ_DEVELOP/Assets/Plugins/* $BUILD_DIR/Assets/Plugins/
#9
echo "删除并拷贝Assets同级目录下的iOSSDK目录"
rm -R $BUILD_DIR/iOSSDK
rsync -aP $PRJ_DEVELOP/iOSSDK/* $BUILD_DIR/iOSSDK/
#10
echo "删除并拷贝build目录下NewInstall"
rm -R $BUILD_DIR/Assets/NewInstall
rsync -aP $PRJ_DEVELOP/Assets/NewInstall/* $BUILD_DIR/Assets/NewInstall/
#11
echo "覆盖场景"
cp -R $PRJ_DEVELOP/Assets/Scene/Launch.unity $BUILD_DIR/Assets/Scene/Launch.unity

echo "SVN提交build目录下的AssetBundles"
cd $BUILD_DIR
#删除所有已经本地删掉的文件和文件夹
$SVN_DIR status | grep '^\!' | cut -c8- | while read f; do $SVN_DIR rm "$f"; done
$SVN_DIR st | grep "^?" | sed 's/^?[ \t]*//g' | sed 's/^/"/g' | sed 's/$/"/g' | xargs $SVN_DIR add
$SVN_DIR commit -m "Build commit AssetBundles" 

echo "SVN提交Develop处理的依赖和AssetBundleName(meta文件)"
cd $PRJ_DEVELOP
$SVN_DIR status|grep ! |awk '{print $2}'|xargs $SVN_DIR del
$SVN_DIR status|grep ? |awk '{print $2}'|xargs $SVN_DIR add
$SVN_DIR commit -m "Develop commit AssetBundleName(meta files)" 

if [ $NeedBuildGame == true ]; 
then
#打包安装包

REPO="/Users/Frozen/Desktop"
PRJ_XCODE="$WORKSPACE/Project/ROIOS"
APP_PATH="build/Release-iphoneos/ro.app"

SIGN_ENT="iPhone Distribution: PinIdea co., Ltd"
PROF_ENT="/Users/Frozen/Documents/buildshell/Anything.mobileprovision"

LASTREVFILE=$REPO/../buildtmp/lastrev-ro
LOCKFILE=$REPO/../buildtmp/autobuilder.isrunning

PRJNAME=$Env"_热更新RO"

cd $BUILD_DIR

rev1=`/opt/subversion/bin/svnversion |sed 's/^.*://' |sed 's/[A-Z]*$//'`


rev1=`echo -n $rev1`
rev="${rev1}"

echo "svn版本号:"
echo $rev

$UNITY_APP_DIR -projectPath $BUILD_DIR -executeMethod EditorTool.ScriptDefines.ExcuteMethodSetEnv $Env $SDK -batchmode -quit

$UNITY_APP_DIR -projectPath $BUILD_DIR -executeMethod EditorTool.BuildParamsJsonEditor.CmdSetPushParams $usePush $pushAppKey $pushIsRelease -batchmode -quit

$UNITY_APP_DIR -projectPath $BUILD_DIR -executeMethod EditorTool.HttpOperationJsonEditor.CmdSetHttpJson $versionURL1 $versionURL2 $versionURL3 plat:$plat -batchmode -quit

if [ $Env == "Studio" ]; then 
	PRJNAME="Studio热更新RO"
fi

if [ -z $ServerVersion ]; then 
	echo "素质差的没填服务器版本号"
    exit 0
fi


$UNITY_APP_DIR -projectPath $BUILD_DIR -executeMethod IOSAutoBuilder.PerformiOSBuildBundleMode $VersionIcon $rev $ServerVersion -batchmode -quit

echo "SVN提交build目录下的"
cd $BUILD_DIR
#删除所有已经本地删掉的文件和文件夹
$SVN_DIR status | grep '^\!' | cut -c8- | while read f; do $SVN_DIR rm "$f"; done
$SVN_DIR st | grep "^?" | sed 's/^?[ \t]*//g' | sed 's/^/"/g' | sed 's/$/"/g' | xargs $SVN_DIR add
$SVN_DIR commit -m "Build commit app build"

#备份xcode
date=`date +%Y_%m_%d_%H_%M`
date=${Branch}_$date
BACKUPXCODEPATH=$PRJ_XCODE/..
mkdir $BACKUPXCODEPATH/${date}

cp -rf ${PRJ_XCODE}/*  $BACKUPXCODEPATH/${date}

cd $BACKUPXCODEPATH/${date}

cp -f temp_files/* ./
rm -rf temp_files

security unlock -p 123

rm -rf build/Release-iphoneos/RODevelop.app

IPAOUTPUT_E="${REPO}/Product/IPA/${PRJNAME}-企业版/${PRJNAME}-${rev}.ipa"

mkdir "${REPO}/Product"
mkdir "${REPO}/Product/IPA"
mkdir "${REPO}/Product/IPA/${PRJNAME}-企业版"

/usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string ${rev}" "Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${rev}" "Info.plist"

xcodebuild -target "Unity-iPhone" -sdk "iphoneos" -configuration Release clean
if [ $? == 0 ]; 
then

sleep 3

else
exit 0
fi

BUNDLEIDENTIFIER=""
#
case $sign in
   pinidea) 
   	  BUNDLEIDENTIFIER="com.pinidea.ent.generalofgods"
	  SIGN_ENT="iPhone Distribution: Shanghai Xindong Enterprise Development Co., Ltd."
	  PROF_ENT="/Users/Frozen/Documents/buildshell/Anything.mobileprovision"
	  PROF_UUID="d1e373a1-566d-4110-8839-97c365091f15"
      ;;
   ROTF_AppStore)
      BUNDLEIDENTIFIER="com.xd.ro1"
      SIGN_ENT="iPhone Distribution: XINDONG Network Inc."
	  PROF_ENT="/Users/Frozen/Documents/buildshell/ROTF-Zeny1/RagnarokOnlineZeny1_AppStore.mobileprovision"
	  PROF_UUID="290f959a-5430-44fe-970d-c8121b75af87"
      ;;
   RO_PushTest)
      BUNDLEIDENTIFIER="com.xd.ro"
      SIGN_ENT="iPhone Developer: Severus Gu"
	  PROF_ENT="/Users/Frozen/Documents/buildshell/RO_Push&Purchase/ro_Development.mobileprovision"
	  PROF_UUID="0d120a4b-6c4e-4c1b-92b9-11f68059c293"
      ;;
   RO_AppStore)
      BUNDLEIDENTIFIER="com.xd.ro"
      SIGN_ENT="iPhone Distribution: XINDONG Network Inc."
	  PROF_ENT="/Users/Frozen/Documents/buildshell/RO_AppStore/RagnarokOnline_AppStore.mobileprovision"
	  PROF_UUID="5b21762d-adeb-41f4-b534-0b68eb062ad2"
      ;;
esac

/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLEIDENTIFIER" "Info.plist"
xcodebuild -target "Unity-iPhone" -sdk "iphoneos" -configuration Release CODE_SIGN_IDENTITY="${SIGN_ENT}" PROVISIONING_PROFILE="${PROF_UUID}" ENABLE_BITCODE=false

if [ $? == 0 ]; 
then
sleep 3
echo "build ipa"
xcrun -l -sdk iphoneos PackageApplication -v "${APP_PATH}" -o "${IPAOUTPUT_E}" --embed "${PROF_ENT}"
sshpass -p 321 scp "${IPAOUTPUT_E}" carlton@172.26.176.1:/Users/carlton/Documents/Product/IPA/RO-企业版

#上传version
cd $WORKSPACE
cd ..
cd MakeZipSendToServer/Proj
$SVN_DIR update

cd version

if [ ! -d "${Env}" ]; then
  mkdir $Env
fi

cd $Env

if [ ! -d "/AssetBundles" ]; then
	if [ $Env == "Develop" ]; then
  		$SVN_DIR co svn://svn.sg.xindong.com/RO/client-trunk/client-refactory/Build/Assets/AssetBundles
    elif [ $Env == "Alpha" ]; then 
    	$SVN_DIR co svn://svn.sg.xindong.com/RO/client-branches/TF/client-refactory/Build/Assets/AssetBundles
    else
    	$SVN_DIR co svn://svn.sg.xindong.com/RO/client-branches/$Env/client-refactory/Build/Assets/AssetBundles
    fi
fi

cd AssetBundles

$SVN_DIR up iOS_Versions.xml

cat iOS_Versions.xml
cd ..
cd ..
cd ..

#python upload_version.py $Env iOS


else
exit 0

fi

else
exit 0
fi
fi
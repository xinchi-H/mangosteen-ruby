user=mangosteen
ip=121.196.236.94

# 当前时间
time=$(date +'%Y%m%d-%H%M%S')
cache_dir=tmp/deploy_cache
# 压缩包的文件名
dist=$cache_dir/mangosteen-$time.tar.gz
# 当前目录（bin目录）
current_dir=$(dirname $0)
# 远程部署目录
deploy_dir=/home/$user/deploys/$time
gemfile=$current_dir/../Gemfile
gemfile_lock=$current_dir/../Gemfile.lock
vendor_cache_dir=$current_dir/../vendor/cache

function title {
  echo 
  echo "###############################################################################"
  echo "## $1"
  echo "###############################################################################" 
  echo 
}


title '打包源代码为压缩文件'
mkdir $cache_dir
# 避免install时候出问题，直接把下载的东西缓存起来，放到vendor目录， 
bundle cache
tar --exclude="tmp/cache/*" --exclude="tmp/deploy_cache/*" -czv -f $dist *
title '创建远程目录'
ssh $user@$ip "mkdir -p $deploy_dir/vendor/cache"
title '上传压缩文件'
scp $dist $user@$ip:$deploy_dir/
yes | rm $dist
scp $gemfile $user@$ip:$deploy_dir/
scp $gemfile_lock $user@$ip:$deploy_dir/
scp -r $vendor_cache_dir $user@$ip:$deploy_dir/vendor/
title '上传 Dockerfile'
scp $current_dir/../config/host.Dockerfile $user@$ip:$deploy_dir/Dockerfile
title '上传 setup 脚本'
scp $current_dir/setup_remote.sh $user@$ip:$deploy_dir/
title '上传版本号'
ssh $user@$ip "echo $time > $deploy_dir/version"
title '执行远程脚本'
ssh $user@$ip "export version=$time; /bin/bash $deploy_dir/setup_remote.sh"

class VolumeController < ApplicationController
  
  def index
    @config = get_conf
    @volumes = Array.new
    volume = Hash.new
    
    file_directory("/mnt")
    
    if get_info.blank?
      flash[:danger] = "Check Server"
    else
      info = get_info.split("\n")
      df = get_df
      puts df
      
      for t in 1..(info.length-1)
        if info[t].include? ":" 
          temp = info[t].split(":")
          volume[temp[0]] = temp[1]
        else
          if df.include? volume['Volume Name'].delete(' ')
            volume['Mount State'] = "Mounted"
          else
            volume['Mount State'] = "UnMounted"
          end
          puts volume['Volume Name'] + ": " + volume['Mount State']
           
          @volumes << volume
          volume = Hash.new
        end
      end
      @volumes << volume
      # puts @volumes
    end
  end

  def get_df
    @config = get_conf
    return `df -P`
  end

  def get_info
    @config = get_conf
    return `sshpass -p#{@config["host_password"]} ssh #{@config["host_port"]} #{@config["host_user"]}@#{@config["host_ip"]} gluster volume info`
  end
  
  def file_upload
    file_name = params[:file]
    uploader = AvatarUploader.new
    uploader.store!(file_name)
    redirect_to '/volume/info'
  end
  
  
  def volume_mount
    @config = get_conf
	  volume_name = params[:volume_name]
	  mount_point = params[:mount_point]
	  volume_name = volume_name.delete(' ')
	  puts "mount -t glusterfs " +  @config["host_ip"] + ":/" + volume_name + " " + mount_point
		
	  `mount -t glusterfs #{@config["host_ip"]}:/#{volume_name} #{mount_point}`
		
	  redirect_to '/volume/index'
  end

  def volume_stop
    @config = get_conf
	  volume_name = params[:volume_name]
	  volume_name = volume_name.delete(' ')
	  puts "gluster volume stop " + volume_name
	  output = `yes | sshpass -p#{@config["host_password"]} ssh #{@config["host_port"]} #{@config["host_user"]}@#{@config["host_ip"]} gluster volume stop #{volume_name}`
    redirect_to '/volume/index'
  end

  def volume_start
    @config = get_conf
	  volume_name = params[:volume_name]
	  volume_name = volume_name.delete(' ')
	  puts "gluster volume start " + volume_name
    output = `sshpass -p#{@config["host_password"]} ssh #{@config["host_port"]} #{@config["host_user"]}@#{@config["host_ip"]} gluster volume start #{volume_name}`
    redirect_to '/volume/index'
  end
  
  
  def volume_delete
    @config = get_conf
	  volume_name = params[:volume_name]
	  volume_name = volume_name.delete(' ')
	  puts "gluster volume delete " + volume_name
	  output = `yes | sshpass -p#{@config["host_password"]} ssh #{@config["host_port"]} #{@config["host_user"]}@#{@config["host_ip"]} gluster volume delete #{volume_name}`
    redirect_to '/volume/index'
  end
end

class FileUpload < ActiveRecord::Base
    require 'fileutils'
    def self.upload(options= {})
        filename = options[:img].original_filename
        dir = IMG_FOLDER
        #encrypted = FileUpload.encrypt(filename)
        require 'securerandom'
        #p SecureRandom.uuid
        encrypted = SecureRandom.uuid
        encrypted = encrypted + ".jpg"
        dirname = File.dirname(dir)
        unless File.directory?(dirname)
            FileUtils.mkdir_p(dir)
        end
        path = File.join(dir,encrypted)
        File.open(path, "wb") { |f| f.write(options[:img].read) }
        imgfile = FileUpload.new(:filename => encrypted,
        :path => path , :status=>1)
        if imgfile.save
            msg="attachment saved"
        end
        imgfile
        #render :json => {success: true}, :status => 200


    end

    private
    def self.encrypt(filename)
        Digest::SHA1.hexdigest(filename)
    end

end


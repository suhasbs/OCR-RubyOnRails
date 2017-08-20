class RunOcrJob < ApplicationJob



  before_perform do |job|
    inp = job.arguments.first
    imgfile = FileUpload.where("id=?", inp).first

    imgfile.status = 2
    imgfile.save
  end

  def perform(*args)
    # Do something later
    imgfile = FileUpload.where("id=?", args[0]).first
    inpImg = imgfile.path
    outputFile = "#{Rails.root}/data/hocrFiles/"+imgfile.filename.split('.')[0]
    a = IO.popen(["tesseract", inpImg, outputFile, "hocr"])
    Process.wait(a.pid)
    #OcrController.job_done

  end

  after_perform do |job|
    #ocr_controller.job_done
    #post processing of hocr file
    inp = job.arguments.first
    imgfile = FileUpload.where("id=?", inp).first

    imgfile.status = 3
    imgfile.save
    #OcrHelper.job_done
  end


end

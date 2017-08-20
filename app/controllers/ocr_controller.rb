
include OcrHelper
require 'nokogiri'

class OcrController < ApplicationController
    skip_before_action :verify_authenticity_token
    def upload


        imgfile = FileUpload.upload(params)

        require 'image_size'
        image = ImageSize.path(imgfile[:path])
        p image.width
        p image.height
        #logger.debug(image.width).inspect
        if image.width!=768 && image.height!=1024
            message="The image uplaoded does not meet the required resolution specification. Please use another device or uplaod an image of resolution 768x1024"
            #return render :json => {success: false, id:session.id, file_id:-1, msg:message}, :status => 200
        end
        session[:filename] = imgfile[:filename]
        session[:path] = imgfile[:path]
        session[:file_id] = imgfile[:id]
        session[:hocr_path] = HOCR_FOLDER+"/"+session[:filename].split('.')[0]

        job = RunOcrJob.perform_later(imgfile[:id])


        render :json => {success: true, id:session.id, file_id:imgfile[:id]}, :status => 200


    end



    def getText(path)
	doc = File.open(path) #{ |f| Nokogiri::XML(f) }
	##puts doc
	@html_doc = Nokogiri::XML(doc)
	#puts html_doc.css("span")
	text = []
	@html_doc.traverse{ |x|
	    if x.text? && x.text !~ /^\s*$/
	        #puts x.text
	        text << x.text
	    end
	}
	puts text
	return text
end

    def processText(text)
        @text = text
        alphNum = []
        @index = []
        ctr=-1
        for word in text
            ctr+=1
            if word =~ /\d/
                alphNum << word
                @index << ctr
            end
        end
        #puts "AlphNum is  :"
        #puts alphNum
        @possible_totals = []

        def findNextNumber(ind)
            for i in @index
                if i>ind
                    break
                end
            end
            if @text[i][/\d+[.]\d+/]!= nil
                puts "appending"
                p @text[i][/\d+[.]\d+/]
                @possible_totals << @text[i][/\d+[.]\d+/]

            elsif @text[i][/\d+/]!= nil
                puts "appending"
                p @text[i][/\d+/]
                @possible_totals << @text[i][/\d+/]
            end
        end

       def findTotal
        possible_words=["total","cash", "net", "inr", "amount", "amt"]
        ctr=-1
        for word in @text
            ctr+=1
            if possible_words.any? { |s| s.include?(word.downcase) } == true
                print word
                ind = ctr
                findNextNumber(ind)
            end
            if word.downcase.include?( "total")
                ind = ctr
                findNextNumber(ind)
            end
            for w in possible_words
                if word.downcase.include? w
                    p word
                    findNextNumber(ctr)
                end
            end
        end
        #p "possible totals:"
        p @possible_totals
        freq = @possible_totals.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
        #p @possible_totals.max_by { |v| freq[v] }
        return @possible_totals.max_by { |v| freq[v] }
       end

       totalAmt = findTotal()
       #p "Total AMt is: #{totalAmt}"
       return totalAmt



    end

    def receive
    #p params[:id]
    #p "in recieve:"


    #p "sleeping"
    #sleep 2
    if FileUpload.where("id=?", params[:id]).first.status != 3
        #p "wait for some time"
        render :json => {success: false}, :status => 200
        return
    end


    hocr_path =  HOCR_FOLDER+"/"+FileUpload.where("id=?", params[:id]).first.filename.split('.')[0]+".hocr"
    session[:hocr_path] =  hocr_path
    coord, total = getCoordinates hocr_path
    render :json=> {coord:coord, total:total}, :status=>200
    end
    def getCoordinates(path)

        text = getText(path)
        #p "text is "
        #p text
        if text.any? == false
        return 0, 0
        end
        totalAmt = processText text
        coord = Hash.new

        if totalAmt == nil
             coord['x1'] = 0
             coord['y1'] = 0
             coord['x2'] = 0
             coord['y2'] = 0
            return coord ,0
        end
        for obj in @html_doc.css("span[class=ocrx_word]")
            word = obj.text
            if word.include? totalAmt
                #p "found"
                obj1 = obj
            end
            if word == totalAmt
                obj1 = obj
                break
             end
        end
        coord = Hash.new
        ctr=0
        for i in obj1['title'].split[1..4]
            if ctr==0
                coord['x1'] = i.to_i
            end
            if ctr==1
                coord['y1'] = i.to_i
            end
            if ctr==2
                coord['x2'] = i.to_i
            end
            if ctr==3
                coord['y2'] = i.to_i
            end
            ctr+=1
        end
        #p coord
        return coord, totalAmt
    end



def getErrorVertex(x1, y1, x2, y2)
	return (x1-x2)**2 + (y1-y2)**2
end



def resend
    coordinates = Hash.new
    coordinates[:x1] = params[:x1]
    coordinates[:y1] = params[:y1]
    coordinates[:x2] = params[:x2]
    coordinates[:y2] = params[:y2]
    #p params[:id]
    doc = File.open(session[:hocr_path]) #{ |f| Nokogiri::XML(f) }
	#puts doc
	@html_doc = Nokogiri::XML(doc)
    ##p coordinates[:x1].to_i
    min_error1 = 1000000
	min_error2 = 1000000
	#p "COORDINATES #{coordinates}"
	@word1=nil
	@word2=nil
	for each in @html_doc.css("span[class=ocrx_word]")
		coord=Hash.new
		ctr=0
		for i in each['title'].split[1..4]
			if ctr==0
				coord['x1'] = i.to_i
			end
			if ctr==1
				coord['y1'] = i.to_i
			end
			if ctr==2
				coord['x2'] = i.to_i
			end
			if ctr==3
				coord['y2'] = i.to_i
			end
			ctr+=1
		end



		e1 = getErrorVertex([coordinates[:x1].to_i, coordinates[:x2].to_i].min, [coordinates[:y1].to_i, coordinates[:y2].to_i].min, coord['x1'].to_i, coord['y1'].to_i)
		e2 = getErrorVertex([coordinates[:x1].to_i, coordinates[:x2].to_i].max, [coordinates[:y1].to_i, coordinates[:y2].to_i].max, coord['x2'].to_i, coord['y2'].to_i)
		if e1 < min_error1
		    #p "error is #{e1}"
			min_error1 = e1
			@word1 = each
			#p "word1 set #{@word1}"

			min_coord1 = coord
		end

		if e2 < min_error2
			min_error2 = e2
			@word2 = each
			min_coord2 = coord
		end
	end
	#p coord

	if @word1
		p "word1 is #{@word1.text}"
	end

	#p "word2 is #{@word2.text}"
	flag=false
	word=""
	for each in @html_doc.css("span[class=ocrx_word]")
		if each == @word1

			flag = true
		end
		if flag
			word = word + " "+each.text
		end
		if each==@word2
			break
		end
	end
    #p "word is #{word}"
	render plain: word

end
end
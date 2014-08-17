module Comics
  require 'csv'

  def export_to_csv(input, output)
    if File.directory?(input)
      Dir.glob(File.join(input, '*xml')) do |file|
        export_to_csv(file, output == STDOUT ? output : File.join(output, "#{file.split('/').last.split('.').first}.csv"))
      end
    else
      xml_in = File.open(input)
      xml_out = output.is_a?(IO) ? output : File.open(output, mode='w')
      do_export_to_csv(xml_in, xml_out)
      xml_in.close
      xml_out.close unless xml_out == STDOUT
    end
  end

  def do_export_to_csv(xml_in, csv_out)
    doc = Nokogiri::XML(xml_in).slop!
    csv_out = csv_out.is_a?(IO) ? csv_out : File.open(csv_out)

    comics = doc.comicinfo.comiclist.comic

    rows = []
    comics.each { |comic|
      issue_nbr = comic.issue.text rescue comic.issuenr.text rescue nil
      rows << [comic.mainsection.series.displayname.text, issue_nbr, comic.location.displayname.text]
    }
    rows.sort do |a,b|
      a[0] == b[0] ? a[1] <=> b[1] : a[0] <=> b[0]
     end

    csv_string = CSV.generate do |csv|
      csv << ['SERIE', 'ISSUE', 'ID', 'LOCATION']
      rows.each do |row|
        csv << row
      end
    end

    csv_out.write csv_string
  end


  def fix_location(input, output, location)
    if File.directory?(input)
      Dir.glob(File.join(input, '*xml')) do |file|
        location = file.split('/').last.split('.').first
        fix_location(file, output == STDOUT ? output : File.join(output, file), location)
      end
    else
      xml_in = File.open(input)
      xml_out = output.is_a?(IO) ? output : File.open(output, mode='w')
      do_fix_location(xml_in, xml_out, location)
      xml_in.close
      xml_out.close unless xml_out == STDOUT
    end
  end

  def do_fix_location(xml_in, xml_out, location)
    doc = Nokogiri::XML(xml_in).slop!
    comics = doc.comicinfo.comiclist.comic
    comics.each { |comic|
      comic.location.displayname.content = location
      comic.location.sortname.content = location
    }

    #xml_out.write doc.to_xml(:save_with => Nokogiri::XML::Node::SaveOptions::DEFAULT_XML | Nokogiri::XML::Node::SaveOptions::NO_EMPTY_TAGS)
    xml_out.write doc.to_xml()
  end


end
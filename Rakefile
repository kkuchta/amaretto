# usage: rake compile\[index.haml\]
# Outputs to out/out.html
# 

desc "Compile to single file"
task :compile, :filename do |t,args|
  puts "Compiling to a single file."

  require 'haml'
  require 'coffee-script'
  require 'sass'
  require 'nokogiri'
  require 'net/http'
  require 'uri'
  require 'Excon'

  inputFile = File.new( args.filename )
  html = inputFile.read()

  if( /\.haml$/ =~ args.filename )
    puts "haml detected, converting to html"
    html =Haml::Engine.new(html).to_html()
  end

  doc = Nokogiri::HTML(html);
  doc.css('script').each do |script|
    puts "script=" + script.inspect
    src = script['src']
    script.delete 'src'
    if( src ) # Skip on-page scripts (like templates)
      scriptContent = getContents( src, 'public' )
      script.children = Nokogiri::XML::Text.new(scriptContent,doc)
    end
  end

  doc.css('link').each do |link|
    puts "link=" + link.inspect
    href = link['href']
    link.delete 'href'
    content = getContents( href, 'public' )
    link.swap( '<style type="text/css">' + content + '</style>' )
    link.children = Nokogiri::XML::Text.new(content,doc)
  end

  File.open('out/out.html', 'w') { |file|
    file.write(doc.serialize())
  }
  
end

# Get the contents of a local file or web url
def getContents( name, dir )
  puts "getting contents"
  if( /^https?:\/\// =~ name )
    begin
      response = Excon.get( name, :expects => [200] )
    rescue Exception => e
      puts "Error - failed to load #{name}, got non-200 code."
      return e
    end
    response.body
  else
    filename = 'public/' + name
    contents = ''

    if File.exists? filename
      contents = File.open(filename).read
    else
      puts "File #{filename} not found"
      
      # Try coffeescript or scss
      if filename.sub!( /\.js$/, '.coffee' ) and File.exists? filename
        contents = CoffeeScript.compile File.open filename
        puts "    But found #{filename}"
      elsif filename.sub!( /\.css$/, '.scss' )and File.exists? filename
        contents = Sass.compile( File.open( filename ).read )
        puts "    But found #{filename}"
      end
    end
    puts "done getting contents"
    contents
  end
end

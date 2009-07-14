module Radical
  module Models
    class Page
      include HappyMapper
      element :id, Integer
      element :title, String
      has_many :parts, PagePart

      def self.from_files(base_dir, id)
        # page attribs
        page_dir = "#{base_dir}/#{id}"
        attribs = YAML.load_file("#{page_dir}/attribs.yml")
        page = new
        page.id = id
        page.title = attribs['title']

        # page parts
        part_ids = Dir["#{page_dir}/parts/*"].collect do |f|
          f.sub(/^.+(\d+)$/, '\1').to_i
        end.sort

        page.parts = []
        part_ids.each do |part_id|
          part_dir = "#{page_dir}/parts/#{part_id}"
          attribs = YAML.load_file("#{part_dir}/attribs.yml")

          part = PagePart.new
          part.id = part_id
          part.name = attribs['name']
          part.content = open("#{part_dir}/content.html").read

          page.parts << part
        end
        page
      end

      def to_files(base_dir)
        files = []
        page_dir = "#{base_dir}/#{self.id}"
        FileUtils.mkdir(page_dir)  if !File.exist?(page_dir)

        # page attributes
        files << "#{page_dir}/attribs.yml"
        File.open(files[-1], 'w') do |f|
          f.print({'title' => self.title}.to_yaml)
        end

        # handle page parts
        parts_dir = "#{page_dir}/parts"
        FileUtils.mkdir(parts_dir) if !File.exist?(parts_dir)
        self.parts.each do |part|
          part_dir = "#{parts_dir}/#{part.id}"
          FileUtils.mkdir(part_dir) if !File.exist?(part_dir)

          files << "#{part_dir}/attribs.yml"
          File.open(files[-1], 'w') do |f|
            f.print({'name' => part.name}.to_yaml)
          end

          files << "#{part_dir}/content.html"
          File.open(files[-1], 'w') do |f|
            f.print part.content
          end
        end
        files
      end
    end
  end
end

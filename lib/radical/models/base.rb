module Radical
  module Models
    module Base
      def self.included(base)
        base.send(:include, HappyMapper)
        base.extend ClassMethods
      end

      module ClassMethods
        def from_files(base_dir, id)
          item = new
          item.id = id

          item_dir = "#{base_dir}/#{id}"
          attribs = YAML.load_file("#{item_dir}/attribs.yml")
          elements.each do |element|
            if element.options.has_key?(:single)
              # omg, it's a sub item!
              sub_dir = "#{item_dir}/#{element.name}"
              sub_ids = Dir.new(sub_dir).grep(/^\d+$/).collect(&:to_i).sort
              sub_items = sub_ids.collect do |sub_id|
                element.type.from_files(sub_dir, sub_id)
              end
              item.send("#{element.method_name}=", sub_items)
            else
              case element.name
              when "id"
              when "content"
                item.content = open("#{item_dir}/content.html").read
              else
                item.send("#{element.method_name}=", attribs[element.name])
              end
            end
          end
          item
        end
      end

      def to_files(base_dir, options = {})
        files = []
        item_dir = "#{base_dir}/#{self.id}"
        FileUtils.mkdir(item_dir)  if !File.exist?(item_dir)

        if options[:symlinks]
          name = self.respond_to?(:name) ? self.name : self.title
          FileUtils.ln_s item_dir, "#{base_dir}/#{name}"
        end

        attribs = {}
        self.class.elements.each do |element|
          value = self.send(element.method_name)
          if element.options.has_key?(:single)
            # omg, it's a sub item!
            sub_dir = "#{item_dir}/#{element.name}"
            FileUtils.mkdir(sub_dir) if !File.exist?(sub_dir)

            value = [value]   if !value.is_a?(Array)
            value.each do |v|
              files += v.to_files(sub_dir, options)
            end
          else
            case element.name
            when "id"
            when "content"
              # content should be its own file
              files << "#{item_dir}/content.html"
              File.open(files[-1], 'w') do |f|
                f.print(value)
              end
            else
              attribs[element.name] = value
            end
          end
        end

        files << "#{item_dir}/attribs.yml"
        File.open(files[-1], 'w') do |f|
          f.print(attribs.to_yaml)
        end
        files
      end

      def to_params
        params = {}
        self.class.elements.each do |element|
          value = self.send(element.method_name)
          if element.options.has_key?(:single)
            if element.options[:single]
              # has_one
              params["#{element.name}_attributes"] = value.to_params
            else
              # has_many
              params["#{element.name}_attributes"] = sub_attribs = {}
              value.each do |sub_item|
                sub_attribs[sub_item.id.to_s] = sub_item.to_params
              end
            end
          else
            params[element.name] = value.to_s
          end
        end
        params
      end

      def to_hash
        hash = {}
        self.class.elements.each do |element|
          value = self.send(element.method_name)
          if element.options.has_key?(:single)
            if element.options[:single]
              # has_one
              hash[element.name] = value.to_hash
            else
              # has_many
              hash[element.name] = value.collect do |sub_item|
                sub_item.to_hash
              end
            end
          else
            hash[element.name] = value
          end
        end
        hash
      end
    end
  end
end

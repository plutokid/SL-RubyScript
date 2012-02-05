require "rubygems"
require 'httparty'
require 'uri'
require 'matrix'

$TYPE_INTEGER	= 1
$TYPE_FLOAT 	= 2
$TYPE_STRING 	= 3
$TYPE_KEY 		= 4
$TYPE_VECTOR 	= 5
$TYPE_ROTATION 	= 6
$TYPE_INVALID 	= 0

$objects = []

class Object
attr_accessor :uuid, :url
	def initialize uuid, url
		@uuid = uuid
		@url = url
	end
	def send_packet type,data
		new_data = []
		data.each do |dat|
			new_data.push to_ll_type dat
		end
		payload = "/"+type+"/"+URI.escape(new_data.join("/"))
		puts payload
		data = Http.get($script_url+payload)
		return data
	end
end
def is_key str
	if str.class == String
		if str.length==36&&str.split("-").length==5
			return true
		end
	end
	return false
end
def serialize_list array
	temp_array = []
	array.each do |data|
		$ll_ruby_types = { Fixnum=>$TYPE_INTEGER,Integer=>$TYPE_INTEGER,Float=>$TYPE_FLOAT,String=>$TYPE_STRING,Vector=>$TYPE_VECTOR }
		type = $ll_ruby_types[data.class]
		result = data.to_s
		if data.class == Vector
			if data.size == 3
				type = $TYPE_VECTOR
				result = "#{data[0].to_f.to_s},#{data[1].to_f.to_s},#{data[2].to_f.to_s}"
			elsif data.size == 4
				type = $TYPE_ROTATION
				result = "#{data[0].to_f.to_s},#{data[1].to_f.to_s},#{data[2].to_f.to_s},#{data[3].to_f.to_s}"
			end
		elsif is_key data
			type == $TYPE_KEY
		end
		temp_array.push type.to_s + "," + result.to_s
	end
	compiled = temp_array.join("$!$")
	puts compiled
	return compiled
end
def unserialize_list data
	array = []
	elements = data.split("$!$")
	elements.each do |elem|
		temp = elem.split(",")
		type = temp[0].to_i
		data = temp[1..temp.length-1].join(",")
		if type == $TYPE_ROTATION
			vec_parts = data.split(",")
			array.push Vector[vec_parts[0].to_f,vec_parts[1].to_f,vec_parts[2].to_f,vec_parts[3].to_f]
		elsif type == $TYPE_VECTOR
			vec_parts = data.split(",")
			array.push Vector[vec_parts[0].to_f,vec_parts[1].to_f,vec_parts[2].to_f]
		elsif type == $TYPE_FLOAT
			array.push data.to_f
		elsif type == $TYPE_INTEGER
			array.push data.to_i
		else
			array.push data
		end
	end
	return array
end
def to_ll_type data
	if data.class == Array
		puts "Serializing Array"
		return serialize_list(data)
	elsif data.class == Vector
		if data.size == 3
			return "<#{data[0].to_f.to_s},#{data[1].to_f.to_s},#{data[2].to_f.to_s}>"
		elsif data.size == 4
			return "<#{data[0].to_f.to_s},#{data[1].to_f.to_s},#{data[2].to_f.to_s},#{data[3].to_f.to_s}>"
		end
	end
	return data.to_s
end
def ll_to_ruby data, type
	if type==$TYPE_INTEGER
		return data.to_i
	elsif type==$TYPE_FLOAT
		return data.to_f
	elsif type==$VECTOR
		
	elsif type==$TYPE_ROTATION
		
	end
	return data
end
class Http
	include HTTParty
end
def touch_start keys
	say 0, "Hello: #{llKey2Name(keys[0])}"
end


llOwnerSay "RubyScript Initialized!"
llOwnerSay("RUBY_VERSION: #{RUBY_VERSION}, RUBY_PLATFORM: #{RUBY_PLATFORM}, RUBY_RELEASE_DATE: #{RUBY_RELEASE_DATE}")

llOwnerSay(llGetListLength(["test",5,1.3]).to_s)


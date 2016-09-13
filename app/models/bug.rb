require 'elasticsearch/model'

class Bug < ApplicationRecord
	include Elasticsearch::Model
	include Elasticsearch::Model::Callbacks

	has_one :state, dependent: :destroy
	accepts_nested_attributes_for :state, allow_destroy: true
	after_save :clear_cache

	auto_increment :number, scope: :application_token, force: true, lock: true
	
	STATUSES = {
		0 => "New",
		1 => "In-progress",
		2 => "Closed"
	} 
	STATUSES_TO_I = {
		"New" => 0,
		"In-progress" => 1,
		"Closed" => 2
	} 

	PRIORITY = {
		0 => "Minor",
		1 => "Major",
		2 => "Critical"
	}
	PRIORITY_TO_I = {
		"Minor" => 0 ,
		"Major" => 1 ,
		"Critical" => 2 
	}

	def self.search(query)
		priority = PRIORITY_TO_I[query] ? PRIORITY_TO_I[query] : ''
		status = STATUSES_TO_I[query] ? STATUSES_TO_I[query] : ''
	  	__elasticsearch__.search({
	      	query: {
	      		dis_max: {
	      			queries: [
	      				{prefix: {comment: query}},
	      				{match: {application_token: query}},
	      				{match: {number: query}},
	      				{match: {status: priority}},
	      				{match: {priority: status}}
	       			]
	      		} 
	    	}
	    })
	end	

	settings index: { number_of_shards: 1 } do
	  	mappings dynamic: 'false' do
		    indexes :comment, analyzer: 'english'
		    indexes :application_token
		    indexes :number
		    indexes :status
		    indexes :priority
	  end
	end


	def self.fetch_count(application_token)
		key = "count_#{application_token}"
	    count =  $redis.get(key)

	    if count.nil?
			count = Bug.where(application_token: application_token).count
			$redis.set(key, count)
			# Expire the cache, every 3 hours
			$redis.expire("categories",3.hour.to_i)
	    end
	    count
  	end

  	def clear_cache
  		key = "count_#{self.application_token}"
  		$redis.del key
  	end
  	
end

# # Delete the previous Bugs index in Elasticsearch
# Bug.__elasticsearch__.client.indices.delete index: Bug.index_name rescue nil

# # Create the new index with the new mapping
# Bug.__elasticsearch__.client.indices.create \
#   index: Bug.index_name,
#   body: { settings: Bug.settings.to_hash, mappings: Bug.mappings.to_hash }

# # Index all Bug records from the DB to Elasticsearch
# Bug.import
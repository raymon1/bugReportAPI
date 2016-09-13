$redis = Redis::Namespace.new("bug_report", :redis => Redis.new)

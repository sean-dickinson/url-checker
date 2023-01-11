require "httparty"
class URLChecker
  def initialize
    @any_results = false
  end

  def check(route)
    resp = HTTParty.get(route)
    return if resp.code == 200
    record_result(route, resp.code)
  end

  def results_message
    if @any_results
      puts "Results can be found in #{results_file_name}"
    else
      puts "All routes returned 200!"
    end
  end

  private

  def results_file_name
    @_file_name ||= Pathname.new("results/#{timestamp}.txt")
  end

  def timestamp
    Time.now.utc.iso8601
  end

  def record_result(route, code)
    @any_results = true
    File.open(results_file_name, "a") do |f|
      f << code.to_s
      f << "\t"
      f << route
      f << "\n"
    end
  end
end

class Routes
  include Enumerable
  def initialize(host: "")
    @host = host
  end

  def each
    File.readlines("routes.txt", chomp: true).each do |line|
      yield build_url(line)
    end
  end

  private

  def build_url(line)
    return line if @host == ""
    sep = line.start_with?("/") ? "" : "/"
    [@host, line].join(sep)
  end
end

url_checker = URLChecker.new
routes = Routes.new(host: "http://localhost:3000")

routes.each do |route|
  url_checker.check(route)
end
puts url_checker.results_message

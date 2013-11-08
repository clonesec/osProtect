namespace :events do
  desc "Add events manually, so we can test notifications."
  # usage: bundle exec rake events:add ... list tasks: bundle exec rake -T
  task :add => :environment do
    # create new events for all sensors:
    Sensor.all.each do |s|
      create_events(s)
    end
  end
end

def create_events(sensor)
  sig = SignatureDetail.where(["sig_name like ?", "%*** report testing ***%"]).first
  unless sig
    sig = SignatureDetail.create!(sig_class_id: 1, sig_name: "*** report testing ***", sig_priority: 1)
  end
  last_event = Event.where(sid: sensor.id).last
  # fake a cid for each sid (stay out of snort's way):
  start_cid = last_event.blank? ? 100_000 : last_event.cid + 100_000
  # create events:
  1.upto(8) do |e|
    cid = start_cid + e
    event = Event.create!(sid: sensor.sid, cid: cid, signature: sig.sig_id, timestamp: Time.now.utc)
    iphdr = Iphdr.create!(sid: sensor.sid, cid: cid, ip_src: 3232238448, ip_dst: 3232238467, ip_proto: 6)
    tcphdr = Tcphdr.create!(sid: sensor.sid, cid: cid, tcp_sport: 58235, tcp_dport: 80, tcp_flags: 24)
  end
end

# namespace :events do
#   desc "Add events manually, so we can test notifications."
#   # usage: bundle exec rake events:add ... list tasks: bundle exec rake -T
#   task :add, [:message] => :environment do |this_task, args|
#     if args.message.nil?
#       puts "Missing args!"
#     else
#       args.with_defaults(:message => "Thanks for logging on")
#       puts "Hello #{User.first.username}. #{args.message}"
#     end
#   end
# end

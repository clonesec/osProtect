module RestrictEventsBasedOnUsersAccess
  extend ActiveSupport::Concern

  def get_events_based_on_groups_for_user(user_id)
    user = User.find(user_id)
    # note: if user is an admin, groups/memberships don't matter since an admin can do anything:
    if user.role? :admin
      @events = Event.includes(:sensor, :signature_detail, :iphdr, :tcphdr, :udphdr).order(timestamp: :desc)
    else
      # only use this user's sensors based on group memberships:
      @events = Event.where("event.sid IN (?)", user.sensors).includes(:sensor, :signature_detail, :iphdr, :tcphdr, :udphdr).order(timestamp: :desc)
    end
    @events
  end

  def filter_events_based_on(criteria)
    # handle any filter/search criteria, if provided:
    @event_search = EventSearch.new(criteria)
    if params.present?
      # if any errors just return and the search/filter form will display them:
      if @event_search.errors.size > 0
        @events = Event.none
      else
        # otherwise let's apply the filter/search criteria to the events relation:
        @events = @event_search.filter @events
      end
    end
  end
end

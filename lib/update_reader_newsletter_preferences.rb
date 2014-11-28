module UpdateReaderNewsletterPreferences
  protected
  def update_newsletter_preference
    # Available to everyone
    %w(fft_newsletter small_scale_forest_grower forest_grower_levy_payer).each do |group_name|
      group = Group.find(NzffaSettings.send("#{group_name})newsletter_group_id"))
      name = group.name =~ /Newsletter/ ? group.name : "#{group.name} Newsletter"
      
      if params["receive_#{group_name}"]
        unless @reader.groups.include? group
          @reader.groups << group
          @newsletter_alert = "Subscribed to #{name}."
        end
      else
        if @reader.groups.include? group
          @reader.groups.delete(group)
          @newsletter_alert = "Unsubscribed from #{name}."
        end
      end
    end
    
    # Full members only
    %w(nzffa_members_newsletter).each do |group_name|
      break unless @reader.full_nzffa_member?
      
      group = Group.find(NzffaSettings.send("#{group_name}_newsletter_group_id"))
      name = group.name =~ /Newsletter/ ? group.name : "#{group.name} Newsletter"
      
      if params["receive_#{group_name}"]
        unless @reader.groups.include? group
          @reader.groups << group
          @newsletter_alert = "Subscribed to #{name}."
        end
      else
        if @reader.groups.include? group
          @reader.groups.delete(group)
          @newsletter_alert = "Unsubscribed from #{name}."
        end
      end
    end
    
  end
end

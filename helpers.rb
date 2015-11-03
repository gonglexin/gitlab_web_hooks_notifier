require 'json'

helpers do
  def titleize(string)
    string.split('_').map(&:capitalize).join(' ')
  end

  def handle_event(event)
    logger.info event
    object_kind = event['object_kind']
    user_name = event['user_name'] || event['user']['name']
    repository = event['repository']['name']
    message, title =
      case object_kind
      when 'push', 'tag_push'
        target = event['ref'].split('/').last
        target_message = object_kind == 'push' ? "to branch #{target} at #{repository}" : "tag #{target} at #{repository}"
        message = "#{user_name} pushed #{target_message}"
        [message, titleize(object_kind)]
      when 'issue', 'merge_request'
        action = "#{event['object_attributes']['action']}"
        object_kind_detail = "#{object_kind.split('_').join(' ')} ##{event['object_attributes']['iid']} #{event['object_attributes']['title']}"
        message = "#{user_name} #{action} #{object_kind_detail} at #{repository}"
        [message, titleize(object_kind)]
      when 'note'
        note = event['object_attributes']['note']
        noteable_type = event['object_attributes']['noteable_type']
        thing =
          case noteable_type
          when 'Commit'
            "commit ##{event['commit']['id']}"
          when 'MergeRequest'
            "merge request ##{event['merge_request']['iid']}"
          when 'Issue'
            "issue ##{event['issue']['iid']}"
          when 'Snippet'
            "snippet ##{event['snippet']['id']}"
          end
        title = "#{user_name} commented on #{thing} at #{repository}"
        [note, title]
      else
        [event, 'Can not parse event response']
      end

    TerminalNotifier.notify(message, title: title)
  end
end

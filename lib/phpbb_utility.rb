class PHPBBUtility
  def self.get_user_ids(conn, card_code)
    return false unless conn
    begin
      find_stmnt = conn.prepare("SELECT user_id FROM phpbb_profile_fields_data WHERE pf_card_code = ?")
      res = find_stmnt.execute(card_code).fetch
      find_stmnt.close
    rescue
      return []
    end
    return res || []
  end
  def self.clear_permissions(conn, user_ids)
    return false unless conn
    clear_stmt = conn.prepare("UPDATE phpbb_users SET user_permissions = '' WHERE user_id = ?")
    user_ids.each do |id|
      clear_stmt.execute(id)
    end
    clear_stmt.close()
  end
end

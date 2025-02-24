# frozen_string_literal: true

require 'etc'

class Entry
  attr_reader :type, :permissions, :nlink, :user, :group, :size, :mtime, :name

  def initialize(entry)
    @entry = entry
  end

  def load_details
    entry_stat = File.lstat(File.join(Dir.pwd, @entry))
    @type = convert_filetype_to_char(entry_stat.ftype)
    @permissions = convert_octal_to_rwx(entry_stat.mode.to_s(8).slice(-4, 4).chars)
    @nlink = entry_stat.nlink
    @user = Etc.getpwuid(entry_stat.uid).name
    @group = Etc.getgrgid(entry_stat.gid).name
    @size = entry_stat.size
    @mtime = format_mtime(entry_stat.mtime)
    @name = entry_stat.symlink? ? "#{@entry} -> #{File.readlink(@entry)}" : @entry
  end

  def to_h
    {
      type: @type,
      permissions: @permissions,
      nlink: @nlink,
      user: @user,
      group: @group,
      size: @size,
      mtime: @mtime,
      name: @name
    }
  end

  private

  def convert_filetype_to_char(ftype)
    case ftype
    when 'file' then '-'
    when 'fifo' then 'p'
    else ftype.chr
    end
  end

  def convert_octal_to_rwx(octal_permissions)
    permissions_map = {
      '7' => 'rwx',
      '6' => 'rw-',
      '5' => 'r-x',
      '4' => 'r--',
      '3' => '-wx',
      '2' => '-w-',
      '1' => '--x',
      '0' => '---'
    }

    special_bit = octal_permissions[0].to_i
    user_rwx = permissions_map[octal_permissions[1]]
    group_rwx = permissions_map[octal_permissions[2]]
    other_rwx = permissions_map[octal_permissions[3]]

    user_rwx = transform_special_bit(user_rwx, special_bit & 4 != 0, 's', 'S')
    group_rwx = transform_special_bit(group_rwx, special_bit & 2 != 0, 's', 'S')
    other_rwx = transform_special_bit(other_rwx, special_bit & 1 != 0, 't', 'T')
    "#{user_rwx}#{group_rwx}#{other_rwx}"
  end

  def transform_special_bit(rwx, has_special_bit, set, unset)
    if has_special_bit
      rwx[0...-1] + (rwx[-1] == 'x' ? set : unset)
    else
      rwx
    end
  end

  def format_mtime(mtime)
    six_months_ago = Date.today << 6
    if mtime.to_date >= six_months_ago
      mtime.strftime('%b %e %H:%M')
    else
      mtime.strftime('%b %e  %Y')
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe Announcement, type: :model do
  it "returns only active announcements in their visibility window" do
    visible = create(:announcement, visible_from: 1.hour.ago, visible_until: 1.hour.from_now)
    create(:announcement, active: false)
    create(:announcement, visible_from: 1.hour.from_now)
    create(:announcement, visible_until: 1.hour.ago)

    expect(described_class.visible_at).to contain_exactly(visible)
  end

  it "orders higher priorities first" do
    low = create(:announcement, priority: 1)
    high = create(:announcement, priority: 10)

    expect(described_class.display_order).to eq([high, low])
  end
end

require "spec_helper"

RSpec.describe ProductHelper, type: :helper do
  include FormResponseHelper

  describe "#ppe_products_with_not_enough_items" do
    it "returns nothing if all ppe products have enough items" do
      session.merge!(valid_data)
      expect(helper.ppe_products_with_not_enough_items).to be_empty
    end

    it "only returns products that don't have enough items" do
      data = valid_data

      data[:product_details].each do |product|
        product[:product_quantity] = (ProductHelper::MINIMUM_ACCEPTED_PRODUCT_QUANTITY - 1).to_s if product[:product_quantity]
      end

      session.merge!(data)
      expect(helper.ppe_products_with_not_enough_items.count).to eq(1)
    end
  end
end

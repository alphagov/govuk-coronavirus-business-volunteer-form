module ProductHelper
  MINIMUM_ACCEPTED_PRODUCT_QUANTITY = 100_000

  def add_product_to_session(product)
    session[:product_details] ||= []
    products = products_except(product.with_indifferent_access[:product_id])
    session[:product_details] = products << product
  end

  def find_product(product_id, products)
    products.find { |product| product[:product_id] == product_id } || {}
  end

  def current_product(product_id, products)
    find_product(product_id, products)
  end

  def remove_product_from_session(product_id)
    session[:product_details] ||= []
    session[:product_details] = products_except(product_id)
  end

  def products_except(product_id)
    session.to_h.with_indifferent_access[:product_details].reject do |prod|
      prod[:product_id] == product_id
    end
  end

  def ppe_products_with_not_enough_items
    all_products = session.to_h.with_indifferent_access[:product_details]
    return [] unless all_products

    products = all_products.map do |product|
      product if product[:product_quantity] && product[:product_quantity].to_i < MINIMUM_ACCEPTED_PRODUCT_QUANTITY
    end

    products.compact
  end
end

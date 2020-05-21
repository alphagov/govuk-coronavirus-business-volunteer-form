module ProductHelper
  def add_product_to_session(product)
    session[:product_details] ||= []
    products = products_except(product.with_indifferent_access[:product_id])
    session[:product_details] = products << format_product(product)
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

  def format_product(product)
    product[:product_quantity] = safe_integer_cast(product[:product_quantity])
    product[:lead_time] = safe_integer_cast(product[:lead_time])
    product
  end

private

  def safe_integer_cast(number)
    Integer(number)
  rescue ArgumentError, TypeError
    nil
  end
end

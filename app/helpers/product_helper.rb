module ProductHelper
  def add_product_to_session(product)
    session[:product_details] ||= []
    products = session[:product_details].reject do |prod|
      prod[:product_id] == product[:product_id]
    end
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
    session[:product_details] = session[:product_details].reject do |prod|
      prod[:product_id] == product_id
    end
  end
end

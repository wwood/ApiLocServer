# A class for dealing with 
class ApilocSweeper < ActionController::Caching::Sweeper
  observe ExpressionContext
  
  def after_create(context)
    expire_expression_context_cache(context)
  end
  
  def after_update(context)
    expire_expression_context_cache(context)
  end
  
  # A DRY method for expiring all pages to do with an expression context
  def expire_expression_context_cache(context)
    # expire everything - too lazy to make this fine grained
    logger.info "removing all caches"
    ApilocController::APILOC_CACHES.each do |cache|
      expire_cache cache
    end
  end
end
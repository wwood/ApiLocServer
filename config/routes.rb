ActionController::Routing::Routes.draw do |map|
  map.connect 'publications/fulltext/:pmid', :controller => 'publications', :action => 'fulltext'
  map.resources :publications, {:fulltext => :put}

  map.resources :expression_contexts

  map.resources :microarrays

  map.resources :signal_ps

  map.resources :signal_ps

  map.resources :annotations

  map.resources :orthomcl_genes

  map.resources :orthomcl_groups

  map.resources :probe_map_entries

  map.resources :probe_maps

  map.resources :coding_region_localisations

  map.resources :localisations

  map.resources :coding_region_alternate_string_ids

  map.resources :cluster_entries

  map.resources :clusters

  map.resources :clustersets

  map.resources :species

  map.resources :go_map_entries

  map.resources :go_maps

  map.resources :go_list_entries

  map.resources :go_lists

  map.resources :scaffolds

  map.resources :plasmodb_gene_lists

  map.resources :cds

  map.resources :go_alternates

  map.resources :generic_go_maps

  map.resources :go_terms

  map.connect 'coding_regions/export/:strings', :controller => 'coding_regions', :action => 'export'
  map.connect 'coding_regions/export', :controller => 'coding_regions', :action => 'export'
  map.connect 'coding_regions/show', :controller => 'coding_regions', :action => 'show'
  map.resources :coding_regions, :member =>  {:annotate => :put, :comment => :get}

  map.resources :genes

  map.resources :taxons

  map.resources :taxon_names

  # genes can, frustratingly, have dots in their IDs, which conflicts somewhat
  # if I wanted to download the information in XML, for instance.
  # Also routes with :species in them should be about ones without, because
  # we want to cache the species-specific pages as well.
  map.connect 'apiloc/gene/:species/:id', :controller => 'apiloc', :action => 'gene'
  map.connect 'apiloc/gene/:species/:id.:id2', :controller => 'apiloc', :action => 'gene'
  map.connect 'apiloc/gene/:species/:id.:id2.:id3', :controller => 'apiloc', :action => 'gene'

  # for annoying gene names like berghei e.g. PB000857.0.0
  map.connect 'apiloc/gene/:id', :controller => 'apiloc', :action => 'gene'
  map.connect 'apiloc/gene/:id.:id2', :controller => 'apiloc', :action => 'gene'
  map.connect 'apiloc/gene/:id.:id2.:id3', :controller => 'apiloc', :action => 'gene'

  map.connect 'apiloc/proteome/:id', :controller => 'apiloc', :action => 'proteome'
  map.connect 'apiloc/proteome/:id.:id2', :controller => 'apiloc', :action => 'proteome'

  map.connect 'expression_contexts/show', :controller => 'expression_contexts', :action => 'show'
  map.resources :expression_contexts

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id', :controller => 'coding_regions', :action => 'index'
  map.connect ':controller/:action/:id.:format'
end

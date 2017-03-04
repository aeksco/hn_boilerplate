
class ViolationModel extends Backbone.Model
  defaults: {}

  isCritical: ->
    return @get('critical_violation') == "Critical Violation"

# # # # #

class ViolationCollection extends Backbone.Collection
  model: ViolationModel
  url: 'https://health.data.ny.gov/resource/5ib6-49en.json'

  comparator: (mod1, mod2) ->
    d1 = new Date(mod1.get('date_of_inspection'))
    d2 = new Date(mod2.get('date_of_inspection'))

    if d1 < d2
      return 1

    else if d2 < d1
      return -1

    else
      return 0

# # # # #

class DataModel extends Backbone.Model
  idAttribute: 'nys_health_operation_id'

  ensureViolations: ->
    return new Promise (resolve, reject) =>

      # Returns if defined
      return resolve(@violations) if @violations

      @violations = new ViolationCollection()
      @violations.fetch
        data: { nys_health_operation_id: @id }
        success: => return resolve(@violations)

# # # # #

# TODO - PAGINATED COLLECTION
class DataCollection extends Backbone.PageableCollection
  model: DataModel
  url: 'https://health.data.ny.gov/resource/5ib6-49en.json'

  mode: 'client'

  state:
    pageSize: 10

  # Paging Helpers
  firstPage: ->
    @getPage( @state.firstPage )

  prevPage: ->
    @getPreviousPage() if @hasPreviousPage()

  nextPage: ->
    @getNextPage() if @hasNextPage()

  lastPage: ->
    @getPage( @state.lastPage )

  query: (data={}) ->
    @fetch({ data: data })

# # # # #

module.exports =
  Model:      DataModel
  Collection: DataCollection

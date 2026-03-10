import { useState } from 'react'
import { router, Link } from '@inertiajs/react'
import { Button } from '@/components/ui/button'
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import {
  Select,
  SelectTrigger,
  SelectContent,
  SelectItem,
  SelectValue
} from '@/components/ui/select'
import type { EventListItem } from '@/types'

const MONTHS = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
]

type Filters = {
  q?: string
  cause?: string
  city?: string
  state?: string
  month?: string
  price_min?: string
  price_max?: string
  industry?: string
}

type HomeProps = {
  events: EventListItem[]
  filters: Filters
  causes: string[]
  industries: string[]
}

function formatDressCode(code: string): string {
  return code
    .split('_')
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(' ')
}

function formatDate(dateStr: string): string {
  const date = new Date(dateStr + 'T00:00:00')
  return date.toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })
}

function formatPrice(price: string | null): string {
  if (!price) return 'Price TBD'
  const num = parseFloat(price)
  if (num === 0) return 'Free'
  return `From $${num.toLocaleString('en-US', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}`
}

export default function Home({ events, filters, causes, industries }: HomeProps) {
  const [filterState, setFilterState] = useState<Filters>(filters)

  function updateFilter(key: keyof Filters, value: string) {
    setFilterState((prev) => ({ ...prev, [key]: value }))
  }

  function applyFilters() {
    const params = Object.fromEntries(
      Object.entries(filterState).filter(([, v]) => v && v !== 'all')
    )
    router.get('/', params, { preserveState: true })
  }

  function clearFilters() {
    setFilterState({})
    router.get('/')
  }

  const hasActiveFilters = Object.values(filterState).some((v) => v && v !== 'all')

  return (
    <div className="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
      <h1 className="text-3xl font-bold tracking-tight mb-6">Upcoming Galas</h1>

      {/* Filter Bar */}
      <Card className="mb-8">
        <CardContent className="pt-6">
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
            <Input
              placeholder="Search events..."
              value={filterState.q || ''}
              onChange={(e) => updateFilter('q', e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && applyFilters()}
            />
            <Select
              value={filterState.cause || 'all'}
              onValueChange={(v) => updateFilter('cause', v)}
            >
              <SelectTrigger>
                <SelectValue placeholder="All causes" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All causes</SelectItem>
                {causes.map((cause) => (
                  <SelectItem key={cause} value={cause}>{cause}</SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Select
              value={filterState.industry || 'all'}
              onValueChange={(v) => updateFilter('industry', v)}
            >
              <SelectTrigger>
                <SelectValue placeholder="All industries" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All industries</SelectItem>
                {industries.map((industry) => (
                  <SelectItem key={industry} value={industry}>{industry}</SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Select
              value={filterState.month || 'all'}
              onValueChange={(v) => updateFilter('month', v)}
            >
              <SelectTrigger>
                <SelectValue placeholder="Any month" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">Any month</SelectItem>
                {MONTHS.map((name, i) => (
                  <SelectItem key={i} value={String(i + 1)}>{name}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-6 mt-4">
            <Input
              placeholder="City"
              value={filterState.city || ''}
              onChange={(e) => updateFilter('city', e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && applyFilters()}
            />
            <Input
              placeholder="State"
              value={filterState.state || ''}
              onChange={(e) => updateFilter('state', e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && applyFilters()}
            />
            <Input
              type="number"
              placeholder="Min price"
              value={filterState.price_min || ''}
              onChange={(e) => updateFilter('price_min', e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && applyFilters()}
            />
            <Input
              type="number"
              placeholder="Max price"
              value={filterState.price_max || ''}
              onChange={(e) => updateFilter('price_max', e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && applyFilters()}
            />
            <Button onClick={applyFilters}>Search</Button>
            {hasActiveFilters && (
              <Button variant="ghost" onClick={clearFilters}>Clear</Button>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Event Grid */}
      {events.length === 0 ? (
        <div className="text-center py-16">
          <p className="text-muted-foreground text-lg mb-4">No events found</p>
          {hasActiveFilters && (
            <Button variant="outline" onClick={clearFilters}>Clear filters</Button>
          )}
        </div>
      ) : (
        <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
          {events.map((event) => (
            <Link key={event.id} href={`/events/${event.id}`} className="block">
              <Card className="h-full transition-colors hover:border-foreground/20">
                <CardHeader>
                  <CardTitle className="line-clamp-2">{event.title}</CardTitle>
                  <CardDescription>
                    <Link
                      href={`/o/${event.organization.slug}`}
                      className="hover:underline"
                      onClick={(e: React.MouseEvent) => e.stopPropagation()}
                    >
                      {event.organization.name}
                    </Link>
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-2 text-sm">
                    <p className="font-medium">{formatDate(event.date)}</p>
                    {(event.city || event.state) && (
                      <p className="text-muted-foreground">
                        {[event.venue_name, event.city, event.state].filter(Boolean).join(', ')}
                      </p>
                    )}
                    <p className="font-semibold">{formatPrice(event.starting_ticket_price)}</p>
                    {event.dress_code && (
                      <Badge variant="outline">{formatDressCode(event.dress_code)}</Badge>
                    )}
                  </div>
                </CardContent>
              </Card>
            </Link>
          ))}
        </div>
      )}
    </div>
  )
}

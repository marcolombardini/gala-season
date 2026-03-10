export type User = {
  id: string
  first_name: string
  last_name: string
  email: string
  username: string
}

export type Organization = {
  id: string
  name: string
  email: string
  slug: string
}

export type Event = {
  id: string
  organization_id: string
  title: string
  description: string | null
  date: string
  start_time: string | null
  end_time: string | null
  venue_name: string | null
  street_address: string | null
  city: string | null
  state: string | null
  zip: string | null
  dress_code: string | null
  starting_ticket_price: string | null
  ticket_link: string | null
  hashtags: string[]
  countdown_timer: boolean
  auction_items: boolean
  gift_items: boolean
  status: 'draft' | 'published'
}

export type EventListItem = {
  id: string
  title: string
  date: string
  venue_name: string | null
  city: string | null
  state: string | null
  starting_ticket_price: string | null
  dress_code: string | null
  status: 'draft' | 'published'
  organization: {
    name: string
    slug: string
  }
}

export type Attendance = {
  id: string
  user_id: string
  event_id: string
}

export type Follow = {
  id: string
  user_id: string
  organization_id: string
}

export type FlashData = {
  notice?: string
  alert?: string
  success?: string
}

export type SharedProps = {
  currentUser: User | null
  currentOrganization: Organization | null
  flash: FlashData
}

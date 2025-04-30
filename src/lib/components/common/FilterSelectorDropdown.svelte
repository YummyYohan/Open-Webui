<script lang="ts">
	import { Select } from 'bits-ui';
	import { flyAndScale } from '$lib/utils/transitions';
	import { createEventDispatcher } from 'svelte';

	import ChevronDown from '../icons/ChevronDown.svelte';
	import Check from '../icons/Check.svelte';
	import Search from '../icons/Search.svelte';

	export let value = '';
	export let placeholder = 'Select a filter';
	export let searchEnabled = true;
	export let searchPlaceholder = 'Search a filter';
	export let filters = [];

	const dispatch = createEventDispatcher();

	let searchValue = '';

	$: filteredItems = searchValue
		? filters.filter((filter) =>
				filter.name.toLowerCase().includes(searchValue.toLowerCase())
			)
		: filters;

	function handleSelectedChange(selectedItem) {
		value = selectedItem.id;
		dispatch('selectedChange', selectedItem);
	}
</script>

<Select.Root
	items={filteredItems}
	onOpenChange={() => {
		searchValue = '';
	}}
	selected={filteredItems.find((filter) => filter.id === value)}
	onSelectedChange={handleSelectedChange}
>
	<Select.Trigger class="relative w-full" aria-label={placeholder}>
		<Select.Value
			class="inline-flex h-input px-0.5 w-full outline-hidden bg-transparent truncate text-lg font-semibold placeholder-gray-400  focus:outline-hidden"
			{placeholder}
		/>
		<ChevronDown className="absolute end-2 top-1/2 -translate-y-[45%] size-3.5" strokeWidth="2.5" />
	</Select.Trigger>

	<Select.Content
		class="w-full rounded-lg bg-white dark:bg-gray-900 dark:text-white shadow-lg border border-gray-300/30 dark:border-gray-700/40  outline-hidden"
		transition={flyAndScale}
		sideOffset={4}
	>
		{#if searchEnabled}
			<div class="flex items-center gap-2.5 px-5 mt-3.5 mb-3">
				<Search className="size-4" strokeWidth="2.5" />
				<input
					bind:value={searchValue}
					class="w-full text-sm bg-transparent outline-hidden"
					placeholder={searchPlaceholder}
				/>
			</div>
			<hr class="border-gray-100 dark:border-gray-850" />
		{/if}

		<div class="px-3 my-2 max-h-80 overflow-y-auto">
			{#each filteredItems as filter}
				<Select.Item
					class="flex w-full font-medium items-center rounded-button py-2 pl-3 pr-1.5 text-sm text-gray-700 dark:text-gray-100 outline-hidden hover:bg-gray-100 dark:hover:bg-gray-850 rounded-lg cursor-pointer data-highlighted:bg-muted"
					value={filter.id}
					label={filter.name}
				>
					{filter.name}
					{#if value === filter.id}
						<div class="ml-auto">
							<Check />
						</div>
					{/if}
				</Select.Item>
			{:else}
				<div class="block px-5 py-2 text-sm text-gray-700 dark:text-gray-100">
					No results found
				</div>
			{/each}
		</div>
	</Select.Content>
</Select.Root>

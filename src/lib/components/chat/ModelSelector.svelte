<script lang="ts">
	import { models, showSettings, settings, user, mobile, config, functions } from '$lib/stores';
	import { onMount, tick, getContext } from 'svelte';
	import { toast } from 'svelte-sonner';
	import Selector from './ModelSelector/Selector.svelte';
	import { getFunctions, toggleGlobalById } from '$lib/apis/functions';
	import Tooltip from '../common/Tooltip.svelte';
	import FiltersSelector from '$lib/components/workspace/Models/FiltersSelector.svelte';
	import Checkbox from '$lib/components/common/Checkbox.svelte';


	import { updateUserSettings } from '$lib/apis/users';

	
	const i18n = getContext('i18n');

	export let selectedModels = [''];
	export let disabled = false;

	export let showSetDefault = true;

	const saveDefaultModel = async () => {
		const hasEmptyModel = selectedModels.filter((it) => it === '');
		if (hasEmptyModel.length) {
			toast.error($i18n.t('Choose a model before saving...'));
			return;
		}
		settings.set({ ...$settings, models: selectedModels });
		await updateUserSettings(localStorage.token, { ui: $settings });

		toast.success($i18n.t('Default model updated'));
	};

	export let filters = [];
	let filterIds = [];
	export let selectedFilterIds = [];

	let _filters = {};

	onMount(async() => {

		await functions.set(await getFunctions(localStorage.token));
		
		//console.log('filters:', filters);
		//console.log('selectedFilterIds:', selectedFilterIds);
		_filters = filters.reduce((acc, filter) => {
			acc[filter.id] = {
				...filter,
				selected: selectedFilterIds.includes(filter.id)
			};
			return acc;
		}, {});
		//console.log('_filters:', _filters);
	});
	//console.log('After mount selectedFilterIds:', selectedFilterIds);

	//console.log('$function', $functions);

	$: console.log('selectedFilterIds changed:', selectedFilterIds);


	
</script>


<div class="flex flex-col w-full items-start">
	{#each selectedModels as selectedModel, selectedModelIdx}
	
		<div class="flex w-full max-w-fit">
			<div class="overflow-hidden w-full">
				<div class="mr-1 max-w-full">
					<Selector
						id={`${selectedModelIdx}`}
						placeholder={$i18n.t('Select a model')}
						items={$models.map((model) => ({
							value: model.id,
							label: model.name,
							model: model
						}))}
						showTemporaryChatControl={$user?.role === 'user'
							? ($user?.permissions?.chat?.temporary ?? true) &&
								!($user?.permissions?.chat?.temporary_enforced ?? false)
							: true}
						bind:value={selectedModel}
						on:click={async (e) => {
							console.log('Change event triggered with detail:', e.detail);
						}}
					/>
				</div>
				<div class="mr-1 max-w-full">
					<Selector
						placeholder="Select a filter"
						items={
						$functions
							? $functions
								.filter((func) => func.type === 'filter')
								.map((filter) => ({
								value: filter.id,
								label: filter.name,
								filter: filter
								}))
							: []
						}
						bind:value={selectedFilterIds}
						on:change={async (e) => {
							const selected = e.detail;
							const filter = $functions.find((f) => f.id === selected);
							console.log('on change Selected filter:', filter);

							if (filter && !filter.is_global) {
								console.log('if');


								try {
									// Set is_global = true for the selected filter
									const updatedSelected = await toggleGlobalById(localStorage.token, filter.id);
									console.log('Updated selected filter:', updatedSelected);

									// set is_global = false for other filters
									const otherFilters = $functions.filter(f => f.id !== selected && f.is_global);

									const updatedOthers = await Promise.all(
										otherFilters.map(f => toggleGlobalById(localStorage.token, f.id).catch(err => {
											console.error('Failed to unset global for ${f.id}:', err);
											return null;
											})
										)
									);

									// update the functions store
									const updatedFunctionMap = new Map();

									$functions.forEach(f => updatedFunctionMap.set(f.id, f));

									// apply updates
									if (updatedSelected) updatedFunctionMap.set(updatedSelected.id, updatedSelected);
									updatedOthers.forEach(f => {
										if (f) updatedFunctionMap.set(f.id, f);
									});

									functions.set([...updatedFunctionMap.values()]);
								} catch (err) {
									console.error('Failed to toggle global filter:', err);
								}
							}
							
						}}
					/>
				</div>
			</div>

			<!-- Removing add model button next to dropdown menu -->
		</div>
	{/each}
</div>

{#if showSetDefault}
	<div class=" absolute text-left mt-[1px] ml-1 text-[0.7rem] text-gray-500 font-primary">
		<button on:click={saveDefaultModel}> {$i18n.t('Set as default')}</button>
	</div>
{/if}



function handles = test_plot_func(handles,x)

if nargin == 0
	% need to make a new figure

	handles.fig = figure('outerposition',[3 3 1000 777],'PaperUnits','points','PaperSize',[1000 777]); hold on
	handles.ax(1) = subplot(2,3,1); hold on
	handles.plot1 = plot(NaN,NaN,'ko-');
	set(gca,'YLim',[0 1])
	xlabel('I_{ext} (nA)')
	ylabel('Duty cycle')

	handles.ax(2) = subplot(2,3,2); hold on
	handles.plot2 = plot(NaN,NaN,'ko-');
	ylabel('Burst frequency (Hz)')
	xlabel('I_{ext} (nA)')
	set(gca,'YLim',[0 4])

	handles.ax(3) = subplot(2,3,3); hold on
	handles.plot3 = plot(NaN,NaN,'ko-');
	ylabel('# spikes/burst')
	xlabel('I_{ext} (nA)')
	set(gca,'YLim',[0 10])

	handles.ax(4) = subplot(2,3,4:6); hold on
	handles.plot4 = plot(NaN,NaN,'k');
	xlabel('Time (ms)')
	ylabel('V (mV)')
	set(handles.ax(4),'YLim',[-80 70])

	prettyFig();
else
	[C, duty_cycle, freq, n_spikes_per_burst, example_V] = test_ext_func(x);
	% update plots
	handles.plot1.XData = linspace(0,1,5);
	handles.plot1.YData = duty_cycle;

	handles.plot2.XData = linspace(0,1,5);
	handles.plot2.YData = freq;

	handles.plot3.XData = linspace(0,1,5);
	handles.plot3.YData = n_spikes_per_burst;

	time = (1:length(example_V))*x.dt;
	handles.plot4.XData = time;
	handles.plot4.YData = example_V;
	set(handles.ax(4),'XLim',[min(time) max(time)])


end	
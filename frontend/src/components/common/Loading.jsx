import './Loading.css';

const Loading = ({
	title = 'Dang tai du lieu',
	subtitle = 'He thong dang chuan bi noi dung cho ban.',
	compact = false,
	className = '',
}) => {
	return (
		<div className={`app-loading ${compact ? 'compact' : ''} ${className}`.trim()}>
			<div className="app-loading-card" role="status" aria-live="polite">
				<div className="app-loading-orbit" aria-hidden="true">
					<span className="app-loading-core" />
					<span className="app-loading-ring ring-one" />
					<span className="app-loading-ring ring-two" />
				</div>

				<div className="app-loading-copy">
					<span className="app-loading-kicker">AI Learning Platform</span>
					<h3>{title}</h3>
					<p>{subtitle}</p>
				</div>

				<div className="app-loading-skeleton" aria-hidden="true">
					<span className="skeleton-line skeleton-line-long" />
					<span className="skeleton-line skeleton-line-mid" />
					<span className="skeleton-line skeleton-line-short" />
				</div>
			</div>
		</div>
	);
};

export default Loading;

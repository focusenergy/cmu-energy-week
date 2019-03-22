from setuptools import setup, find_packages


def readme():
    with open('README.md') as f:
        return f.read()

setup(
    name='test_harness',
    version='0.1',
    description='Test harness for CMU load forecasting challenge',
    python_requires='>= 3.6',
    long_description=readme(),
    url='https://gitlab.windlogics.com/internal/amg/cmu-energy-week.git',
    author='NextEra Analytics, Inc.',
    author_email='Brian.Baingana@nexteraanalytics.com',
    license='Commercial',
    package_dir={'': 'src'},
    packages=find_packages('src'),
    install_requires=['pandas', 'numpy'],
)

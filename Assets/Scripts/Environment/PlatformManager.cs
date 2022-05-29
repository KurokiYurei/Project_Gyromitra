using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlatformManager : MonoBehaviour
{
    [SerializeField]
    private List<MovingPlatform> m_platforms;

    public int m_readyPlatforms;

    public delegate void OnMovePlatformsDelegate();
    public OnMovePlatformsDelegate OnMovePlatforms;

    void Update()
    {
        if(m_readyPlatforms == m_platforms.Count)
        {
            MovePlatforms();
        }
    }
    private void MovePlatforms()
    {
        OnMovePlatforms?.Invoke();
        m_readyPlatforms = 0;
    }
}
